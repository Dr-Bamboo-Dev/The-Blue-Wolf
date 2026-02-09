extends Node

@export var music_dir_path:String = "res://audio/music/"
@export var sfx_dir_path:String = "res://audio/sfx/"
@export var music_duck_curve:Curve = null
@export var music_unduck_curve:Curve = null
@onready var duck_hold_timer: Timer = $DuckHoldTimer

var sfx_file_paths:PackedStringArray = []
var sound_effects:Dictionary[StringName,PackedStringArray] = {}
var total_sfx_puffs:int = 0

var newest_track:MusicPuff = null
var old_track:MusicPuff = null
var total_music_puffs:int = 0
var ducking_music:bool = false
var music_duck_tween:Tween = null

const BUS_LAYOUT:String = "res://autoloads/audio_manager/casual_music_mix.tres"
const MASTER_INDEX:int = 0
const BUS_NAMES:PackedStringArray = ["Master", "Music1", "SFX"]


func _ready() -> void:
	AudioServer.set_bus_layout(load(BUS_LAYOUT))
	sound_effects = get_sound_effects()
	#print(sound_effects)

func get_sound_effects(
	type:String="WAV",absolute_path:bool=false) -> Dictionary[StringName,PackedStringArray]:
	var fetched_sfx:Dictionary[StringName,PackedStringArray]
	var sfx_dir:PackedStringArray = ResourceLoader.list_directory(sfx_dir_path)
	
	for file_name in sfx_dir:
		if file_name[file_name.length()-1] != "/":
			if file_name.get_extension().to_upper() == type:
				var new_sound_effect:PackedStringArray = [file_name]
				fetched_sfx.set(file_name.get_basename(),new_sound_effect)
	
	for dir_name in sfx_dir:
		if dir_name[dir_name.length()-1] == "/":
			var sfx_variant_paths:PackedStringArray = [dir_name]
			var full_path:String = sfx_dir_path + sfx_variant_paths[0]
			sfx_variant_paths.append_array(get_file_paths_recursive(full_path,type,absolute_path))
			fetched_sfx.set(dir_name.get_slice("/",0),sfx_variant_paths)
	
	var alphabetized_sfx:Dictionary[StringName,PackedStringArray]
	var sorted_sfx_keys:PackedStringArray = fetched_sfx.keys(); sorted_sfx_keys.sort()
	for key in sorted_sfx_keys:
		alphabetized_sfx.set(key, fetched_sfx[key])
	
	return alphabetized_sfx

func get_file_paths_recursive(
	dir_path:String, type:String, absolute:bool=true, paths:PackedStringArray=[],
	top_dir:String="") -> PackedStringArray:
	var dir:PackedStringArray = ResourceLoader.list_directory(dir_path)
	if top_dir == "": top_dir = dir_path
	
	for file_name in dir:
		if file_name[file_name.length()-1] != "/":
			if file_name.get_extension().to_upper() == type.to_upper():
				if absolute:
					paths.append(dir_path + file_name)
				else:
					var start_char_num:int = top_dir.length()
					var local_dir_path:String = dir_path.right(-start_char_num)
					paths.append(local_dir_path + file_name)
	
	for d in dir:
		if d[d.length()-1] == "/":
			if d != "." and d != "..":
				get_file_paths_recursive(dir_path + d, type, absolute, paths, top_dir)
	
	return paths


func play_sfx(sfx_name:StringName,volume:float=0,pitch:float=0,variation:int=0) -> void:
	var sfx_path:String = get_path_to_sound_effect(sfx_name,variation)
	var sfx_player:SFXPuff = SFXPuff.new()
	sfx_player.name = "SFXPuff" + str(total_sfx_puffs)
	total_sfx_puffs += 1
	sfx_player.stream = load(sfx_path)
	sfx_player.volume_db = volume
	sfx_player.sfx_basename = sfx_name
	if pitch == 0:
		var random_pitch:float = randf_range(0.8,1.2)
		sfx_player.pitch_scale = random_pitch
	else:
		sfx_player.pitch_scale = pitch
	add_child(sfx_player)

func kill_all_sfx(sfx_type:StringName=&"*") -> void:
	var sounds:Array[Node] = get_children()
	for sound in sounds:
		if sound is SFXPuff:
			if (sfx_type == &"*") or (sound.sfx_basename == sfx_type):
				sound.volume_db = -80.0
				sound.queue_free()

## Variation of 0 selects a random variation of the sound effect.
func get_path_to_sound_effect(sfx_name:StringName,variation:int=0) -> String:
	var sfx:PackedStringArray = sound_effects[sfx_name]
	var sfx_path:String = ""
	if sound_effects[sfx_name].size() == 1:
		sfx_path = sfx_dir_path + sfx[0]
	elif sfx.size() > 1:
		if variation == 0:
			var random_variant:String = sfx[randi_range(1,sfx.size()-1)]
			sfx_path = sfx_dir_path + sfx[0] + random_variant
		elif variation > 0:
			var selected_variant:String = sfx[variation]
			sfx_path = sfx_dir_path + sfx[0] + selected_variant
		else: push_error("Invalid sound effect variation: ", variation)
	else: push_error("Empty array value in sound_effects Dictionary at: ", sfx_name)
	return sfx_path

# Make a new version of music ducking that does not use Tweens so it can be interupted and extended.
func duck_music(duck_db:float=10,tween_duration:float=0.5,hold_duration:float=0.0) -> void:
	if ducking_music: push_warning("Already ducking music! New duck canceled."); return
	ducking_music = true
	var reset_music_duck_tween:Callable = func() -> void:
		if music_duck_tween: music_duck_tween.kill()
		music_duck_tween = create_tween()
		music_duck_tween.set_ease(Tween.EASE_IN)
		music_duck_tween.set_trans(Tween.TRANS_LINEAR)
	var get_duck_curve:Callable = func(progress:float)->void:
		var new_volume:float = -music_duck_curve.sample(progress)*duck_db
		AudioServer.set_bus_volume_db(1, new_volume)
	var get_unduck_curve:Callable = func(progress:float)->void:
		var new_volume:float = -music_unduck_curve.sample(progress)*duck_db
		AudioServer.set_bus_volume_db(1, new_volume)
	var unduck:Callable = func():
		if hold_duration > 0.0: 
			duck_hold_timer.start(hold_duration)
			await duck_hold_timer.timeout
		reset_music_duck_tween.call()
		music_duck_tween.tween_method(get_unduck_curve, 0.0, 1.0, tween_duration)
		#var duck_done:Callable = func(): ducking_music = false
		music_duck_tween.tween_callback(func(): ducking_music = false)
	
	reset_music_duck_tween.call()
	music_duck_tween.tween_method(get_duck_curve, 0.0, 1.0, tween_duration)
	music_duck_tween.tween_callback(unduck)

# Instances in a new MusicPuff to the AudioManager.
func add_track(track_name:String, fade_in_time:float=0.0, start_position:float=0.0) -> void:
	var track_dir:String = music_dir_path + track_name + ".ogg"
	var new_track:MusicPuff = MusicPuff.new()
	new_track.name = "MusicPuff" + str(total_music_puffs)
	new_track.set_bus(BUS_NAMES[1])
	total_music_puffs += 1
	if fade_in_time > 0.0:
		new_track.fade_in_on_ready = true
		new_track.fade_in(fade_in_time, true)
	add_child(new_track)
	new_track.add_to_group("MusicPuff")
	
	new_track.stream = load(track_dir)
	new_track.play(start_position)
	newest_track = new_track

## This is good for major threshold triggers such as entering a building or cutscene.
func crossfade_to_track(track_name:String, keep_position:bool=true, crossfade_time:float=1.0) -> void:
	if get_child_count() > 1:
		var children:Array[Node] = get_children()
		for child in children:
			if child.is_in_group("MusicPuff") and child.fading_out == true:
				child.queue_free()
	
	kill_all_tracks(crossfade_time)
	if keep_position:
		if newest_track:
			add_track(track_name, crossfade_time, newest_track.get_playback_position())
		else:
			add_track(track_name, crossfade_time, 0.0)
	else:
		add_track(track_name, crossfade_time)

## This kills all MusicPuffs with on optional fade time.
func kill_all_tracks(fade_out_time:float=0.0) -> void:
	var children = get_children()
	for child in children:
		if child is MusicPuff:
			if fade_out_time > 0.0: child.fade_out(fade_out_time)
			else: queue_free()

func pause_all_tracks() -> void:
	var children = get_children()
	for child in children:
		if child is MusicPuff:
			child.stream_paused = true

func resume_all_tracks() -> void:
	var children = get_children()
	for child in children:
		if child is MusicPuff:
			child.stream_paused = false
