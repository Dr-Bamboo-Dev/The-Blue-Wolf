extends Node

const PAUSE_DELAY:int = 2
var delay_left:int = PAUSE_DELAY
var game_has_focus:bool = true

func _ready():
	get_viewport().focus_entered.connect(_on_window_focus_in)
	get_viewport().focus_exited.connect(_on_window_focus_out)
	
func _on_window_focus_in():
	delay_left = PAUSE_DELAY
	game_has_focus = true
	get_tree().paused = false
	if WolfStats.wolf == null: return
	var refresh_input:Vector2 = Input.get_vector("move_west","move_east","move_north","move_south")
	WolfStats.wolf.input_vector = (refresh_input + SignalBus.touch_joystick_vector).limit_length()

func _on_window_focus_out():
	game_has_focus = false

func _process(_delta: float) -> void:
	if game_has_focus: return
	if delay_left < 0: return
	if delay_left > 0:
		delay_left -= 1
	else:
		pause_game()
		delay_left -= 1

func pause_game() -> void:
	get_tree().paused = true
