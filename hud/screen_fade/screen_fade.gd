extends ColorRect

signal fade_out_complete
signal fade_in_complete

var fade_out_tween:Tween = null
var fade_in_tween:Tween = null

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _ready() -> void:
	visible = true

#-----------------------------------------
# Local Functions
#-----------------------------------------
func fade_out(duration:float=1.0) -> void:
	modulate.a = 0.0
	fade_out_tween = create_tween()
	fade_out_tween.set_trans(Tween.TRANS_SINE)
	fade_out_tween.set_ease(Tween.EASE_OUT)
	fade_out_tween.tween_property(self, "modulate:a", 1, duration)
	fade_out_tween.tween_callback(fade_out_complete.emit).set_delay(1)

func fade_in(duration:float=1.0) -> void:
	modulate.a = 1.0
	fade_in_tween = create_tween()
	fade_in_tween.set_trans(Tween.TRANS_SINE)
	fade_in_tween.set_ease(Tween.EASE_OUT)
	fade_in_tween.tween_property(self, "modulate:a", 0, duration)
	fade_in_tween.tween_callback(fade_in_complete.emit)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
