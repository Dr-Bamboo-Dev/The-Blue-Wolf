extends Node2D


@onready var lyric_animator:AnimationPlayer = $LyricAnimator
@onready var lyric_player:AudioStreamPlayer = $LyricPlayer
var animation_pos:float = 0.0
var song_pos:float = 0.0
var song_length:float = 0.0

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	song_length = lyric_player.stream.get_length()
	AudioManager.kill_all_tracks()
	#AudioManager.add_track("credits_theme")
	lyric_player.play()
	lyric_animator.animation_finished.connect(_on_song_end)
	lyric_animator.play(&"lyrics")

func _process(_delta: float) -> void:
	animation_pos = lyric_animator.current_animation_position
	song_pos = lyric_player.get_playback_position()
	if abs(animation_pos - song_pos) > 0.1:
		lyric_player.seek(clamp(animation_pos, 0.0, song_length))


#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_song_end(anim_name:StringName) -> void:
	if anim_name == &"lyrics":
		print("SONG ENDED. RETURNING TO MAIN MENU.")
		get_tree().change_scene_to_file("res://title_screen/title_screen.tscn")
