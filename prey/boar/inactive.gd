extends State

@export var boar:CharacterBody2D = null
@export var boar_sprite:Sprite2D = null
@export var animator:AnimationPlayer = null

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	animator.play(&"RESET")
	boar_sprite.visible = false

func exit() -> void:
	boar_sprite.visible = true
	AudioManager.kill_all_tracks(0.5)
	AudioServer.set_bus_volume_db(1,-3)
	AudioManager.add_track("ravenous")

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_boar_vis_notifier_screen_entered() -> void:
	if is_active:
		transitioned.emit(self, &"Idle")
