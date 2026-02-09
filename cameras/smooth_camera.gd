extends Camera2D
## SmoothCamera2D moves much like a CharacterBody2D with smooth movement, following directional key
## inputs, but is bound to a player by a leash which prevents it from running away.
class_name SmoothCamera2D

@export_subgroup("Input")
## Input Actions
@export var move_north:InputEventAction = null
@export var move_south:InputEventAction = null
@export var move_west:InputEventAction = null
@export var move_east:InputEventAction = null

@export_subgroup("Leash")
## Assign the player to leash the camera to. If no player is assigned, it will be unleased.
@export var player:Node2D = null
## Set if the SmoothCamera2D moves in global space or relative to the player.
@export var relative_to_player:bool = false
## How far the camera can wander from the player. Separate x and y lengths can be set.
@export var leash_length:Vector2 = Vector2(200,100)
## How much force the leash exherts on the camera when it starts to wander near its limit.
@export var max_pull:float = 10
## The amount of counter force per discance from the center.
@export var elastic_pull_curve:Curve = preload("uid://bsx2sapruy7fj")
## How much extra force gets appled when turning around sharply.
@export var pull_boost_strength:float = 6
## Curve
@export var pull_boost_curve:Curve = preload("uid://4jxfl7g4jicr")

@export_subgroup("Movement")
## Set how quickly the camera can change velocity.
@export var acceleration:float = 0.25
## The camera's maximum speed it can move at.
@export var max_speed:float = 10  # 5.833

@export_subgroup("Effects")
## The camera's screen shake curve
@export var shake_curve:Curve = preload("uid://cnfdbcnuf3go0")

## Camera can only be controlled when enabled
var movement_controls_enabled:bool = true : set = set_movement_controls_enabled

## The normalized Vector2 which represents the input direction.
var input_vector:Vector2 = Vector2.ZERO
## The movement force currently stored in the camera movement.
var inertia:Vector2 = Vector2.ZERO
## The camera's current velocity which updates every physics frame.
var velocity:Vector2 = Vector2.ZERO
## The position the camera is at without offsets
var physical_position:Vector2 = Vector2.ZERO
## Position relative to player.
var rtp_position:Vector2 = Vector2.ZERO
## Leash bounds, updated every physics frame.
var bounds:PackedVector2Array = []
## Physics framerate.
var physics_fps:float = 60

## Direction of screen shake
var screen_shake_dir:Vector2 = Vector2.RIGHT
## Magnitude of screen shake
var screen_shake_mag:float = 10.0
## Duration of screen shake in seconds.
var screen_shake_duration:float = 0.0
## Duration of screen shake in frames.
var screen_shake_frames:int = 0
## Progress of screen shake. Counts up from 0 to screen_shake_frames.
var screen_shake_progress:int = 0
## Determines if new screen shake is starting this frame
var screen_shake_starting:bool = false
## Min domain of screen shake curve
var screen_shake_dmin:float = 0.0
## Max domain of screen shake curve
var screen_shake_dmax:float = 1.0
## The actual screen shake offset added to the camera position
var screen_shake_offset:Vector2 = Vector2.ZERO

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _notification(what:int):
	if what == NOTIFICATION_ENTER_TREE:
		physics_fps = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
		if move_north==null or move_south==null or move_west==null or move_east==null:
			push_warning("Set all inputs or the camera cannot move!"); return

func _ready() -> void:
	Camera.current_camera = self
	physical_position = global_position
	_update_shake_curve_data()

func _physics_process(delta: float) -> void:
	_update_screen_shake()
	_update_rtp()
	_update_leash_bounds()
	_update_inertia(delta)
	_update_velocity(delta)
	_apply_velocity(delta)
	WolfStats.wolf_camera_global_position = global_position

func _unhandled_input(event:InputEvent) -> void:
	#if event.is_echo(): return
	#if event is InputEventKey and event.keycode == KEY_K and event.is_pressed():
		#screen_shake(Vector2.LEFT, 20, 0.2)
	
	if not event.is_action_type(): return
	if event.is_echo(): return
	if not movement_controls_enabled: return
	input_vector = Input.get_vector(move_west.action,move_east.action,move_north.action,move_south.action)

func _exit_tree() -> void:
	Camera.current_camera = null


#-----------------------------------------
# Local Functions
#-----------------------------------------
func set_movement_controls_enabled(new_state:bool) -> void:
	if new_state == false: input_vector = Vector2.ZERO
	movement_controls_enabled = new_state

func _update_inertia(delta:float) -> void:
	var move_vector:Vector2 = input_vector * max_speed * delta * physics_fps
	var new_inertia:Vector2 = inertia
	var pull_boost:Vector2
	pull_boost.x = remap(move_vector.x - rtp_position.x/leash_length.x*10,-20,20,-1,1)
	pull_boost.x = pull_boost_curve.sample(abs(pull_boost.x)) * pull_boost_strength
	pull_boost.y = remap(move_vector.y - rtp_position.y/leash_length.y*10,-20,20,-1,1)
	pull_boost.y = pull_boost_curve.sample(abs(pull_boost.y)) * pull_boost_strength
	
	new_inertia.x = new_inertia.move_toward(
		move_vector, (acceleration+abs(pull_boost.x)) * delta * physics_fps).x
	new_inertia.y = new_inertia.move_toward(
		move_vector, (acceleration+abs(pull_boost.y)) * delta * physics_fps).y
	
	
	 #Hard limit inertia at edge of least range.
	if abs(physical_position.x - bounds[0].x) < 1:
		if move_vector.x > 0: new_inertia.x = maxf(new_inertia.x, 0.0)
	elif abs(physical_position.x - bounds[1].x) < 1:
		if move_vector.x < 0: new_inertia.x = minf(new_inertia.x, 0.0)
	if abs(physical_position.y - bounds[0].y) < 1:
		if move_vector.y > 0: new_inertia.y = maxf(new_inertia.y, 0.0)
	elif abs(physical_position.y - bounds[1].y) < 1:
		if move_vector.y < 0: new_inertia.y = minf(new_inertia.y, 0.0)
	
	inertia = new_inertia

func _update_velocity(_delta:float) -> void:
	var new_vel = inertia + get_pull_vector()
	velocity = new_vel

func _apply_velocity(delta:float) -> void:
	var new_pos:Vector2
	new_pos = physical_position + velocity * delta * physics_fps
	new_pos = new_pos.clamp(bounds[0],bounds[1])
	var new_rtp:Vector2
	new_rtp = rtp_position + velocity * delta * physics_fps
	new_rtp = new_rtp.clamp(-leash_length,leash_length)
	if relative_to_player:
		set_rtp_position(new_rtp)
	else:
		global_position = new_pos + screen_shake_offset
		rtp_position = new_rtp

func get_rtp_position() -> Vector2:
	if player == null: push_error("Cannot get rtp_position. No player assigned."); return Vector2.ZERO
	return physical_position - player.global_position

func _update_rtp() -> void:
	rtp_position = get_rtp_position()

func set_rtp_position(new_pos:Vector2) -> void:
	if player == null: push_error("Cannot set rtp_position. No player assigned."); return
	rtp_position = new_pos
	physical_position = player.global_position + new_pos
	global_position = physical_position + screen_shake_offset

func _update_leash_bounds() -> void:
	bounds = get_leash_bounds()

## Get the global positions of the leash bounding box.
func get_leash_bounds() -> PackedVector2Array:
	var northwest_bound:Vector2 = Vector2(
		player.global_position.x - leash_length.x, player.global_position.y - leash_length.y)
	var southeast_bound:Vector2 = Vector2(
		player.global_position.x + leash_length.x, player.global_position.y + leash_length.y)
	return [northwest_bound,southeast_bound]

## Get elastic pull strength at given distance between 0 and 1.
func get_elastic_pull(x_position:float) -> float:
	var x_pos:float = clamp(x_position,0,1)
	return elastic_pull_curve.sample(x_pos)

func get_pull_vector(norm_max:bool=false) -> Vector2:
	if max_pull <= 0: return Vector2.ZERO
	
	var x_dist:float = Vector2.ZERO.distance_to(Vector2(rtp_position.x,0))
	var y_dist:float = Vector2.ZERO.distance_to(Vector2(0,rtp_position.y))
	
	var x_pull:float = get_elastic_pull(remap(x_dist,0,leash_length.x,0,1))
	if rtp_position.x > 0: x_pull = x_pull * -1
	var y_pull:float = get_elastic_pull(remap(y_dist,0,leash_length.y,0,1))
	if rtp_position.y > 0: y_pull = y_pull * -1
	
	if norm_max:
		x_pull = clamp(x_pull, -1, 1)
		y_pull = clamp(y_pull, -1, 1)
	else:
		x_pull = clamp(x_pull * max_pull, -max_pull, max_pull)
		y_pull = clamp(y_pull * max_pull, -max_pull, max_pull)
	
	return Vector2(x_pull,y_pull)

func screen_shake(direction:Vector2, magnitude:float, duration:float=0.2) -> void:
	_update_shake_curve_data()
	direction = direction.normalized()
	screen_shake_dir = direction
	screen_shake_mag = magnitude
	screen_shake_duration = duration
	screen_shake_frames = int(duration * 60)
	screen_shake_starting = true

func _update_screen_shake() -> void:
	if screen_shake_starting:
		screen_shake_progress = 0
		screen_shake_starting = false
	
	if screen_shake_progress < screen_shake_frames:
		var curve_sample_point:float = remap(
			screen_shake_progress, 0, screen_shake_frames, screen_shake_dmin, screen_shake_dmax,)
		var curve_sample_value:float = shake_curve.sample(curve_sample_point)
		screen_shake_offset = screen_shake_dir * screen_shake_mag * curve_sample_value
		screen_shake_progress += 1


func _update_shake_curve_data() -> void:
	screen_shake_dmin = shake_curve.min_domain
	screen_shake_dmax = shake_curve.max_domain

#-----------------------------------------
# Signal Functions
#-----------------------------------------
