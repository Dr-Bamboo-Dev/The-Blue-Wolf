extends CharacterBody2D


@onready var boar_sprite:Sprite2D = $BoarSprite
@onready var ouch_area:Area2D = $OuchArea
@onready var attack_area:Area2D = $AttackArea
@onready var aim_debug:Line2D = $AimDebug
@onready var wall_ray:RayCast2D = $WallRay
@onready var attack_area_shape:CollisionShape2D = $AttackArea/AreaShape
@onready var wall_area:Area2D = $WallArea
@onready var ouch_eye_sprite:Sprite2D = $BoarSprite/OuchEyeSprite
@onready var boar_squeal:AudioStreamPlayer2D = $BoarSqueal
@onready var flash_timer:Timer = $FlashTimer
@onready var state_machine: StateMachine = $StateMachine
@onready var boar_shape: CollisionShape2D = $BoarShape

var damage_particles:PackedScene = preload("uid://dp3bhuj57ieww")
var explode_particles:PackedScene = preload("uid://yycgxnxqbtpy")

const MAX_HEALTH:int = 20
var health:int = 20 : set = set_health
const MAX_RAGE:int = 1
var rage:float = 0
var face_direction:Vector2 = Vector2.RIGHT : set = set_face_direction
var aim_direction:Vector2 = Vector2.RIGHT
var max_speed:float = 1200.0
var speed:float = 0.0
var attack_state:bool = false : set = set_attack_state

#-----------------------------------------
# Inherited Functions
##-----------------------------------------
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_echo(): return
	#if event is InputEventKey and event.keycode == KEY_Q and event.is_pressed():
		#die()

#-----------------------------------------
# Local Functions
#-----------------------------------------
func set_health(new_hp:int) -> void:
	var valid_hp:int = clampi(new_hp, 0, MAX_HEALTH)
	health = valid_hp

func inflict_damage(dp:int) -> void:
	var valid_dp:int = clampi(dp, 0, health)
	health = health - valid_dp
	var rage_increase:float = remap(float(valid_dp), 0.0, float(MAX_HEALTH), 0.0, MAX_RAGE)
	rage += rage_increase

func set_face_direction(direction:Vector2) -> void:
	var dir:Vector2 = direction.normalized()
	var face_left:bool
	if dir.x > 0.0: face_left = false
	elif dir.x < 0.0: face_left = true
	
	boar_sprite.flip_h = face_left
	ouch_area.position = flip_position_x(ouch_area.position,face_left)
	attack_area.position = flip_position_x(attack_area.position,face_left)
	wall_area.position = flip_position_x(wall_area.position,face_left)
	ouch_eye_sprite.position = flip_position_x(ouch_eye_sprite.position,face_left)

	face_direction = dir
	var aim_pos:Vector2 = face_direction * 140
	aim_pos.y = aim_pos.y * 0.5
	aim_debug.set_point_position(1,aim_pos)
	wall_ray.target_position = aim_pos

func flip_position_x(pos:Vector2, reverse:bool=false) -> Vector2:
	var flipped_position:Vector2 = pos
	if reverse: flipped_position.x = -(absf(flipped_position.x))
	else: flipped_position.x = (absf(flipped_position.x))
	return flipped_position

func aim_at_wolf() -> void:
	aim_direction = global_position.direction_to(WolfStats.global_position)
	#if is_wall_nearby() and (not is_wolf_nearby()):
		#aim_direction.x = max(0.8, abs(aim_direction.x)) * sign(aim_direction.x)
		#aim_direction.y = min(0.6, abs(aim_direction.y)) * sign(aim_direction.y)
		#aim_direction = aim_direction.normalized()
	face_direction = aim_direction

func aim_away_from_wolf() -> void:
	aim_direction = WolfStats.global_position.direction_to(global_position)
	face_direction = aim_direction

func aim_at_arena_center() -> void:
	aim_direction = global_position.direction_to(LevelStats.arena_center)
	face_direction = aim_direction

func aim_at_point(target_point:Vector2) -> void:
	aim_direction = target_point
	face_direction = aim_direction

func dash_forward(dash_speed:float) -> void:
	var delta_one:float = get_physics_process_delta_time() * 60
	var dash_vector:Vector2 = face_direction * dash_speed * delta_one
	velocity = dash_vector
	move_and_slide()

func set_attack_state(state:bool) -> void:
	attack_state = state
	attack_area_shape.set_deferred("disabled", not state)

func is_wolf_nearby() -> bool:
	var wolf_near:bool = false
	for body in wall_area.get_overlapping_bodies(): if body.name == "Wolf": wolf_near = true; break
	return wolf_near

func random_flee_direction() -> Vector2:
	var center_pos_dir:Vector2 = global_position.direction_to(LevelStats.arena_center)
	var random_deviation:float = randf_range(-30,30)
	var new_random_flee_dir:Vector2 = center_pos_dir.rotated(deg_to_rad(random_deviation))
	return new_random_flee_dir

func set_wolf_collision(new_state:bool) -> void:
	if new_state:
		collision_layer = 12
	else:
		collision_layer = 8

func flash(duration:float=0.2) -> void:
	boar_sprite.material.set_shader_parameter("active", true)
	flash_timer.start(duration)

func spawn_damage_particles() -> void:
	var new_damage_particles:Node2D = damage_particles.instantiate()
	#new_damage_particles.global_position = global_position
	new_damage_particles.global_position = WolfStats.wolf.get_node("ChompZone/ChompShape").global_position
	new_damage_particles.z_index = z_index
	var level_ysort:Node2D = get_tree().current_scene.get_node("YSort")
	level_ysort.add_child(new_damage_particles)

func die() -> void:
	for state in state_machine.get_children():
		if state.has_method("_on_death"):
			state._on_death()
	print("DEAD!")

func shake_strength_from_speed(collision_speed:float) -> float:
	var shake_strength:float = remap(
		collision_speed, 0, 1200, 0, 18)
	return shake_strength


#-----------------------------------------
# Signal Functions
#-----------------------------------------

func _on_attack_area_area_entered(area: Area2D) -> void:
	var clash_force:float = 0.0
	clash_force = (WolfStats.velocity - velocity).length()
	
	var get_damage:Callable = func()->float:
		if clash_force >= 666.0: 
			return clamp(remap(clash_force,666,1200,0,1),0,1)
		else: return 0.0
	var damage_dealt:float = get_damage.call()*25 + 6
	WolfStats.wolf.damage(damage_dealt)
	
	var shove_vector:Vector2 = Vector2.ZERO
	if clash_force >= 666.0:
		area.take_damage(damage_dealt)
		shove_vector = global_position.direction_to(WolfStats.global_position) * clash_force * 2
		shove_vector = shove_vector.limit_length(2400)
		var shove_sfx_amp:float = remap(shove_vector.length(), 666, 2400, -10.0, 0.0)
		AudioManager.play_sfx(&"boar_hit",shove_sfx_amp)
		print(shove_vector)
	WolfStats.wolf.shove(shove_vector)

func _on_ouch_area_area_entered(_area: Area2D) -> void:
	if health > 0:
		flash(0.1)
		boar_squeal.play()
	spawn_damage_particles()
	ouch_eye_sprite.visible = true
	boar_squeal.pitch_scale = randf_range(0.8, 1.2)
	inflict_damage(1)
	if health == 0:
		boar_shape.set_deferred("disabled", true)
		call_deferred("die")
	#print("Boar Health: ", health, "       Rage: ", rage)

func _on_flash_timer_timeout() -> void:
	boar_sprite.material.set_shader_parameter("active", false)
