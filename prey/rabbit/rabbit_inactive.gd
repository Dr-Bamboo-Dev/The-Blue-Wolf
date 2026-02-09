extends State

@export var rabbit_sprite:Sprite2D = null
@export var rabbit_animator:AnimationPlayer = null

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	rabbit_animator.stop()
	rabbit_animator.play(&"RESET")
	rabbit_sprite.visible = false

func exit() -> void:
	rabbit_sprite.visible = true
	

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_rabbit_vis_notifier_screen_entered() -> void:
	if is_active:
		transitioned.emit(self, &"RabbitHop")
