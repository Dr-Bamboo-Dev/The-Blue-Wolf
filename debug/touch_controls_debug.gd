extends Node2D

@onready var floating_touch_joystick:Node2D = $FloatingTouchJoystick
@onready var joystick_output:Label = $JoystickOutput

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	floating_touch_joystick.output_changed.connect(_on_joystick_output_changed)

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_joystick_output_changed(new_value:Vector2) -> void:
	joystick_output.text = str("Joystick output: " , new_value)
