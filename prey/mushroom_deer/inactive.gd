extends State
class_name DeerInacive

@export var mushroom_deer:CharacterBody2D = null

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	mushroom_deer.velocity = Vector2.ZERO

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_deer_vis_notifier_screen_entered() -> void:
	if mushroom_deer.is_chomped:
		transitioned.emit(self, "DeerChomped")
	else:
		transitioned.emit(self, "DeerIdle")
