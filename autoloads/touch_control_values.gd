extends Node

var joystick_vector:Vector2 = Vector2.ZERO
var attack_button_pressed:bool = false


func set_joystick_vector(new_vector) -> void:
	joystick_vector = new_vector
