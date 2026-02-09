extends WolfState

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	animator.play(&"die")
	AudioManager.kill_all_tracks(0.5)

func physics_update(_delta:float) -> void:
	wolf.velocity = wolf.shove_vector
	wolf.move_and_slide()

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
