extends AudioStreamPlayer
class_name SFXPuff

var sfx_basename:StringName = ""

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	finished.connect(_on_finished)
	play()

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_finished() -> void:
	queue_free()
