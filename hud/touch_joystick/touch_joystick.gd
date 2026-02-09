extends Node2D

signal output_changed(new_value:Vector2)

var base_scale:float = 170.0
var stick_scale:float = 72.0
var stick_range:float = 170.0 / 2
var stick_held:bool = false
var stick_return_speed:float = 0.2
var touch_index:int = -1
var joystick_vector:Vector2 = Vector2.ZERO
var fade_out_tween:Tween = null
## Change this value to make the joystick bigger or smaller.
@export var scale_multiplier:float = 1
## Cange this number to adjust the joystick deadzone.
@export var stick_deadzone:float = 5.0
## Hide the joystick when not in use.
@export_category("Auto Hide")
## Set whether the joystick hides when not in use.
@export var auto_hide_active:bool = true
## Set how long the joystick stays visible before auto hiding in seconds.
@export var hide_delay:float = 0.2
## Set how long the fade out lasts for in seconds.
@export var fade_length:float = 0.2
@onready var stick:MeshInstance2D = $Stick
@onready var base:MeshInstance2D = $Base
@onready var touch_area:Area2D = $TouchArea
@onready var hide_delay_timer:Timer = $HideDelayTimer

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	touch_area.input_event.connect(_on_touch_event)
	hide_delay_timer.timeout.connect(_on_hide_delay_timeout)
	update_joystick_scale()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed == true: return
		if event.index != touch_index: return
		touch_index = -1
		stick_held = false
		if not auto_hide_active: return
		start_auto_hide()
	elif event is InputEventScreenDrag:
		if stick_held and event.index == touch_index:
			var local_drag_pos:Vector2 = event.position - position
			stick.position = local_drag_pos.limit_length(stick_range)
			update_stick_vector()
			output_changed.emit(joystick_vector)

func _draw() -> void:
	update_joystick_scale()

func _physics_process(delta:float) -> void:
	var delta_1:float = delta*60
	if not stick_held:
		var previous_pos:Vector2 = stick.position
		stick.position = stick.position.move_toward(Vector2.ZERO,stick_range*stick_return_speed)*delta_1
		if previous_pos != stick.position:
			update_stick_vector()
			output_changed.emit(joystick_vector)
	
	

#-----------------------------------------
# Local Functions
#-----------------------------------------
func update_joystick_scale() -> void:
	base.mesh.radius = base_scale/2 * scale_multiplier
	base.mesh.height = base_scale * scale_multiplier
	stick.mesh.radius = stick_scale/2 * scale_multiplier
	stick.mesh.height = stick_scale * scale_multiplier
	stick_range = base.mesh.radius

func update_stick_vector() -> void:
	if stick.position.length() <= stick_deadzone:
		joystick_vector = Vector2.ZERO
	else:
		joystick_vector = (stick.position/stick_range).limit_length(stick_range)

func start_auto_hide() -> void:
	if not hide_delay_timer.is_stopped(): hide_delay_timer.stop()
	if hide_delay >= 0.05:
		hide_delay_timer.wait_time = hide_delay
		hide_delay_timer.start()
	else:
		fade_out()

func fade_out() -> void:
	if fade_out_tween: fade_out_tween.kill()
	fade_out_tween = create_tween()
	fade_out_tween.set_ease(Tween.EASE_IN)
	fade_out_tween.set_trans(Tween.TRANS_SINE)
	fade_out_tween.tween_property(self,"modulate:a",0.0,fade_length)

func pop_in() -> void:
	if fade_out_tween: fade_out_tween.kill()
	hide_delay_timer.stop()
	modulate.a = 1.0

func instant_hide() -> void:
	if fade_out_tween: fade_out_tween.kill()
	hide_delay_timer.stop()
	modulate.a = 0.0

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_touch_event(_viewport:Node, event:InputEvent, _shape_index:int) -> void:
	if not event is InputEventScreenTouch: return
	if event.is_pressed():
		stick_held = true
		touch_index = event.index

func _on_hide_delay_timeout() -> void:
	fade_out()
