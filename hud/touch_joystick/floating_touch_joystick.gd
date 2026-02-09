extends Node2D

signal output_changed(new_output:Vector2)

var signal_bus:Node = SignalBus
@export var start_hidden:bool = true
@onready var float_area:Area2D = $FloatArea
@onready var touch_joystick:Node2D = $TouchJoystick

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	if start_hidden: touch_joystick.instant_hide()
	float_area.input_event.connect(_on_float_area_input_event)
	touch_joystick.output_changed.connect(_on_touch_joystick_output_changed)
	
	if not signal_bus: 
		push_warning("SignalBus not found."); 
		return
	if not signal_bus.has_method("transmit_touch_joystick_output"): 
		push_warning("Method \"transmit_touch_joystick_output()\" not found in SignalBus.");
		return
	
	output_changed.connect(signal_bus.transmit_touch_joystick_output)


#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_float_area_input_event(_viewport:Node, event:InputEvent, _shape_index:int) -> void:
	if not (event is InputEventScreenTouch and event.is_pressed()): return
	touch_joystick.position = event.position
	touch_joystick.pop_in()
	touch_joystick.stick_held = true
	touch_joystick.touch_index = event.index

func _on_touch_joystick_output_changed(new_value:Vector2) -> void:
	output_changed.emit(new_value)
