extends Control

signal pressed
signal released

@export_range(0.1, 1.0, 0.01) var button_size:float = 0.5
@onready var actual_button:TouchScreenButton = $ActualButton
@onready var starting_self_modulate_a:float = actual_button.self_modulate.a

func _ready() -> void:
	pass
	# I added this manual anchor set to make the warning stop. It might mess things up. Idk.
	#anchor_left = 0; anchor_right = 1280; anchor_top = 0; anchor_bottom = 270
	#size = size * button_size
	
	#actual_button.scale = Vector2(button_size, button_size)
	#set_deferred("size", size * button_size) #size = size * button_size
	#position.x = (get_viewport_rect().size.x - size.x) - (size.x * 0.5)
	#get_viewport_rect()
	#position.y = size.y

func _on_actual_button_pressed() -> void:
	actual_button.self_modulate.a = 0.8
	pressed.emit()

func _on_actual_button_released() -> void:
	actual_button.self_modulate.a = starting_self_modulate_a
	released.emit()
