extends Node2D


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	$Emitter.emitting = true

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_emitter_finished() -> void:
	queue_free()
