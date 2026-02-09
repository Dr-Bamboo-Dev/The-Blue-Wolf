## AudioStreamPlayer that can be faded in and out
class_name MusicPuff
extends AudioStreamPlayer

## The tween responsible for adjusting the volume_db during fade_in and fade_out.
var fade_tween:Tween = null
var fade_in_on_ready:bool = false
var default_fade_time:float = 1.0
var fading_out:bool = false

func _ready() -> void:
	if fade_in_on_ready: fade_in()

## Fade in the current music track.
func fade_in(fade_time:float=default_fade_time, reset_volume:bool=true) -> void:
	if reset_volume: volume_db = -80
	elif volume_db == 0: push_warning("Volume already full. Fade in canceled."); return
	
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN_OUT)
	fade_tween.set_trans(Tween.TRANS_LINEAR)
	fade_tween.tween_method(smooth_step_fade_volume, 1.0, 0.0, fade_time)

## Fade out the current music track and queue free.
func fade_out(fade_time:float=default_fade_time, reset_volume:bool=true) -> void:
	fading_out = true
	if reset_volume: volume_db = 0
	elif volume_db == -80: push_warning("Volume already minimum. Fade out canceled."); return
	
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN_OUT)
	fade_tween.set_trans(Tween.TRANS_LINEAR)
	fade_tween.tween_method(smooth_step_fade_volume, 0.0, 1.0, fade_time)
	fade_tween.tween_callback(queue_free)

## Give a delta between 0.0 and 1.0, and it will set the volume to a smoothed value between mute and normal.
func smooth_step_fade_volume(delta:float) -> void:
	var smooth_step:float = (pow(delta, 4.5) * 80) - 80
	smooth_step = remap(smooth_step, 0, -80, -80, -0)
	volume_db = smooth_step
