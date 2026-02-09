extends Node

var funni_cursor:Texture2D = preload("uid://cbhspol7rj4gn")
#var cursor_frame:Sprite2D = Sprite2D.new()

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _init() -> void:
	RenderingServer.set_default_clear_color(Color(0,0,0,1))

#func _ready() -> void:
	#cursor_frame.name = "CursorFrame"
	#add_child(cursor_frame)
	#print(cursor_frame.get_tree_string_pretty())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_custom_mouse_cursor(funni_cursor,Input.CURSOR_POINTING_HAND)
	if event is InputEventKey:
		if Input.get_vector("move_west","move_east","move_north","move_south").length() > 0:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
