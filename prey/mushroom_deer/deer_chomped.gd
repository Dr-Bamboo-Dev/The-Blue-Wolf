extends State
class_name DeerChomped

signal chomped

@export var mushroom_deer:CharacterBody2D = null
@export var deer_animator:AnimationPlayer = null

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func enter() -> void:
	if not mushroom_deer.is_chomped:
		deer_animator.play("chomped")
		mushroom_deer.is_chomped = true
		chomped.emit()
		mushroom_deer.velocity = Vector2.ZERO


#-----------------------------------------
# Local Functions
#-----------------------------------------
func _got_chomped() -> void:
	chomped.emit()
	mushroom_deer.queue_free()


#-----------------------------------------
# Signal Functions
#-----------------------------------------
