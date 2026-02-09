extends Control

enum side {
	##Place touch area on the left side of the screen.
	LEFT,
	##Place touch area on the right side of the screen.
	RIGHT}

@export_range(0.1, 1.0, 0.01) var touch_area_size:float = 0.5
@export_range(0.1, 1.0, 0.01) var joystick_size:float = 0.25
@export var screen_side:side = side.LEFT

@onready var joystick_base:Sprite2D = $TouchJoystick/Base
@onready var j_base_dimensions:Vector2 = joystick_base.texture.get_size()
@onready var j_base_size:float = min(
	get_viewport_rect().size.y, 
	get_viewport_rect().size.x) * joystick_size
@onready var touch_joystick:Control = $TouchJoystick
@onready var touch_button:Control = $TouchButton


func _ready() -> void:
	joystick_base.scale = Vector2(j_base_size, j_base_size) / j_base_dimensions

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		visible = true
	elif event is InputEventKey:
		visible = false
