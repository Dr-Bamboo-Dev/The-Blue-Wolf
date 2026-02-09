extends Node2D

signal spin_finished

@onready var animation_player:AnimationPlayer = $AnimationPlayer

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _init() -> void:
	visible = false

func _ready() -> void:
	animation_player.animation_finished.connect(anim_finished)
	animation_player.play("RESET")

#-----------------------------------------
# Local Functions
#-----------------------------------------
func anim_finished(anim_name:StringName) -> void:
	if anim_name == &"RESET":
		visible = true
		animation_player.play("Speen")
	elif anim_name == &"Speen":
		spin_finished.emit()
		queue_free()

#-----------------------------------------
# Signal Functions
#-----------------------------------------
