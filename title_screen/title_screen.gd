extends Control

@onready var screen_fade:ColorRect = $ScreenFade
@onready var play:Button = $Play
@onready var music_delay:Timer = $MusicDelay
@onready var debug_touch_controls:Button = $DebugTouchControls
@onready var pine_background: TextureRect = $PineBackground
@onready var mist_background: TextureRect = $MistBackground


var start_triggered:bool = false
var fade_in_complete:bool = false

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _ready() -> void:
	GameProgress.gems_collected = [0,0,0]
	screen_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	AudioServer.set_bus_volume_db(1, 0)
	screen_fade.fade_in(1.0)
	music_delay.start(0.2) # Beginning of first audio cut off when running on browser.
	# Pause added before to hopefully prevent it.
	debug_touch_controls.gui_input.connect(_on_debug_touch_controls_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if fade_in_complete:
			start_game()

func _physics_process(delta: float) -> void:
	var old_time:float = pine_background.material.get_shader_parameter("shader_time")
	pine_background.material.set_shader_parameter("shader_time", (old_time + 1.0/60.0) * delta * 60)
	mist_background.material.set_shader_parameter("shader_time", (old_time + 1.0/60.0) * delta * 60)


	#if event.is_action_pressed("ui_accept"):
		#play.set_pressed(true)
		#trigger_mouse_click(true, Vector2(sim_click_pos.global_position))
	#elif event.is_action_released("ui_accept"):
		#play.set_pressed(false)
		#trigger_mouse_click(false, Vector2(sim_click_pos.global_position))

#-----------------------------------------
# Local Functions
#-----------------------------------------
func fade_out() -> void:
	screen_fade.fade_out()

func trigger_mouse_click(pressed:bool, pos:Vector2=Vector2.ZERO) -> void:
	var event_lmb:InputEventMouseButton = InputEventMouseButton.new()
	event_lmb.position = pos
	event_lmb.button_index = MOUSE_BUTTON_LEFT
	if pressed:
		event_lmb.pressed = true
		Input.parse_input_event(event_lmb)
		await get_tree().process_frame
	else:
		event_lmb.pressed = false
		Input.parse_input_event(event_lmb)
		await get_tree().process_frame

func start_game() -> void:
	if start_triggered: return
	start_triggered = true
	#AudioManager.crossfade_to_track("on_the_prowl",false,5.0)
	AudioManager.kill_all_tracks(1.0)
	fade_out()
	

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_play_pressed() -> void:
	start_game()

func _on_screen_fade_out_complete() -> void:
	get_tree().change_scene_to_file("res://world/main_level/main_level.tscn")

func _on_screen_fade_fade_in_complete() -> void:
	screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_in_complete = true

func _on_play_gui_input(event: InputEvent) -> void:
	if event.is_echo(): return
	if event is InputEventScreenTouch:
		if event.is_pressed():
			start_game()

func _on_music_delay_timeout() -> void:
	AudioManager.add_track("the_blue_wolf")

func _on_debug_touch_controls_pressed(event:InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		get_tree().change_scene_to_file("res://debug/touch_controls_debug.tscn")
		AudioManager.kill_all_tracks()
