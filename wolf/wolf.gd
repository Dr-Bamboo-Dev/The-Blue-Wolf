extends CharacterBody2D

var button_input_vector:Vector2 = Vector2.ZERO
var touch_input_vector:Vector2 = Vector2.ZERO
var input_vector:Vector2 = Vector2.ZERO
var move_vector:Vector2 = Vector2.ZERO

var auto_target_pos:Vector2 = Vector2.ZERO
var max_speed:float = 21000
var acceleration:float = 5000
var deceleration:float = 2500
var dash_boost:float = 3.5
var dash_available:bool = true
var bite_atailable:bool = true
enum face_direction {LEFT, RIGHT}
var active_face_direction:face_direction = face_direction.RIGHT
@onready var chomp_zone: Area2D = $ChompZone
@onready var wolf_sprite:Sprite2D = $WolfSprite
@onready var wolf_animator:AnimationPlayer = $WolfAnimator
@onready var behavior_machine:StateMachine = $BehaviorMachine

var active_state:StringName = &"Auto"
var movement_controls_enabled:bool = true :
	set = set_movement_controls_enabled
var shove_vector:Vector2 = Vector2.ZERO
var win_condition_met:bool = false

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _ready() -> void:
	SignalBus.touch_joystick_output_changed.connect(_on_touch_joystick_output_changed)
	behavior_machine.state_changed.connect(_on_behavior_state_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo(): return
	if (event is InputEventKey) or (event is InputEventJoypadMotion) or (event is InputEventJoypadButton):
		button_input_vector = Input.get_vector("move_west","move_east","move_north","move_south")
		update_input_vector()

func _physics_process(delta: float) -> void:
	if velocity.length() > 0.0:
		WolfStats.global_position = global_position
	shove_vector = shove_vector.move_toward(Vector2.ZERO, deceleration*delta)
	if get_slide_collision_count() > 0:
		shove_vector = Vector2.ZERO


#-----------------------------------------
# Local Functions
#-----------------------------------------
func shove(force_vector:Vector2) -> void:
	shove_vector = force_vector

func damage(damage_amount:float) -> void:
	WolfStats.dash_drain(damage_amount)

func die() -> void:
	pass

func update_input_vector() -> void:
	if movement_controls_enabled:
		input_vector = (button_input_vector + touch_input_vector).limit_length(1.0)
	else:
		input_vector = Vector2.ZERO

func update_move_vector() -> void:
	var delta:float = get_physics_process_delta_time()
	var max_move_vector:Vector2 = input_vector * max_speed * delta
	move_vector = move_vector.move_toward(max_move_vector, acceleration * delta)

func auto_move_vector() -> void:
	var delta:float = get_physics_process_delta_time()
	var max_move_vector:Vector2 = global_position.direction_to(auto_target_pos) * max_speed * delta
	move_vector = move_vector.move_toward(max_move_vector, acceleration * delta)


func set_movement_controls_enabled(new_status:bool) -> void:
	movement_controls_enabled = new_status
	update_input_vector()

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_touch_joystick_output_changed(new_value) -> void:
	touch_input_vector = new_value
	update_input_vector()

func _on_behavior_state_changed(new_state) -> void:
	active_state = new_state
