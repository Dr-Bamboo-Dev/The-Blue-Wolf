extends Node2D

var trees:Array[Node2D] = []
@onready var screen_fade:ColorRect = $FlashBackground/ScreenFade
@onready var wolf:CharacterBody2D = $YSort/Wolf
@onready var wolf_cam:Camera2D = $SmoothCamera
@onready var render_zone:Area2D = $SmoothCamera/RenderZone
@onready var flash_background:Node2D = $FlashBackground
@onready var floating_touch_joystick:Node2D = $FlashBackground/FloatingTouchJoystick
@onready var flash:ColorRect = $FlashBackground/Flash
@onready var touch_screen_button:TouchScreenButton = $FlashBackground/TouchScreenButton
@onready var wolf_auto_target:Marker2D = $WolfAutoTarget
var gem_spin_1:PackedScene = preload("res://items/gem/gem_spinner/gem_spin_1/gem_spin_1.tscn")
var touch_control_mode:bool = false
var gems:Array


#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _ready() -> void:
	#wolf_cam.global_position = wolf.global_position
	wolf.auto_target_pos = wolf_auto_target.global_position
	SignalBus.red_mole_switch_state = true
	LevelStats.arena_center = $ArenaCenter.global_position
	WolfStats.wolf = wolf
	WolfStats._set_hunger_points(WolfStats.max_hunger_points)
	
	AudioServer.set_bus_volume_db(1, -3)
	AudioManager.add_track("on_the_prowl",0.0,0.5)
	WolfStats.hunger_drain_paused = true
	WolfStats._set_hunger_points(WolfStats.max_hunger_points)
	fade_in()
	
	wolf.movement_controls_enabled = true
	
	gems = get_tree().get_nodes_in_group("gem")
	for gem in gems:
		gem.collected.connect(_on_gem_collected)
	await get_tree().create_timer(0.8).timeout
	floating_touch_joystick.output_changed.connect(_on_touch_joystick_output_changed)
	
	#wolf.global_position = $CheatTeleport.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch: touch_control_mode = true
	elif event is InputEventKey: touch_control_mode = false
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion: touch_control_mode = false
	
	if touch_control_mode:
		touch_screen_button.visible = true
	else:
		touch_screen_button.visible = false


	#if event.is_echo(): return
	#if event is InputEventKey and event.keycode == KEY_Q and event.is_pressed():
		#GameProgress.gems_collected = [1,1,1]
		#ascension_flash()

#-----------------------------------------
# Local Functions
#-----------------------------------------
func fade_out() -> void:
	screen_fade.fade_out()

func fade_in() -> void:
	screen_fade.fade_in()

func ascension_flash() -> void:
	wolf.win_condition_met = true
	wolf.z_index = 5
	wolf.movement_controls_enabled = false
	wolf_cam.movement_controls_enabled = false
	var new_gem_spin:Node2D = gem_spin_1.instantiate()
	new_gem_spin.z_index = -1
	wolf.add_child(new_gem_spin)
	new_gem_spin.position.y = -25
	new_gem_spin.spin_finished.connect(_on_gem_spin_finished)
	fade_in_flash()
	AudioManager.kill_all_tracks(0.25)
	AudioManager.play_sfx("wolf_ascension", 0.0, 1.0, 0)

# Called from WolfStats
func _on_death() -> void:
	wolf.die()
	fade_out()

func set_flash_alpha(new_alpha:float) -> void:
	flash.color.a = new_alpha

func fade_in_flash() -> void:
	var flash_tween:Tween = create_tween()
	flash_tween.tween_method(set_flash_alpha, 0.0, 1.0, 0.7)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_screen_fade_out_complete() -> void:
	WolfStats.hunger_drain_paused = true
	WolfStats.wolf = null
	if wolf.active_state == &"Dead":
		get_tree().change_scene_to_file("res://title_screen/title_screen.tscn")
	elif GameProgress.gems_collected == GameProgress.all_gems:
		get_tree().change_scene_to_file("res://credits/credits_screen.tscn")

func _on_gem_collected(type:int) -> void:
	@warning_ignore("unused_variable")
	var type_name:String = "NULL"
	match type:
		0: 
			type_name = "Chaos Gem"
			#dialogue_choice = dialogues["Chaos Gem get"]
		1: 
			type_name = "The Xyrelith"
			#dialogue_choice = dialogues["The Xyrelith get"]
		2: 
			type_name = "Amyth Crystal"
			#dialogue_choice = dialogues["Amyth Crystal get"]


func _on_prop_exited_screen(prop:Node2D) -> void:
	prop.hide_sprite()

func _on_prop_entered_screen(prop:Node2D) -> void:
	prop.show_sprite()

func _on_boss_door_trigger_body_entered(_body: Node2D) -> void:
	SignalBus.red_mole_switch_state = false
	$Walls/BossDoorTrigger.set_deferred("monitoring", false)

func _on_quiet_trigger_body_entered(_body: Node2D) -> void:
	AudioManager.kill_all_tracks(3.0)

func _on_gem_spin_finished() -> void:
	screen_fade.fade_out()

func _on_touch_joystick_output_changed(new_value:Vector2) -> void:
	wolf.touch_input_vector = new_value
