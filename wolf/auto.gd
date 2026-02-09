extends WolfState


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	animator.play(&"walk")

func exit() -> void:
	WolfStats.hunger_drain_paused = false

func physics_update(delta:float) -> void:
	wolf.auto_move_vector()
	wolf.velocity = wolf.move_vector
	wolf.move_and_slide()
	
	if wolf.global_position.distance_to(wolf.auto_target_pos) <= wolf.move_vector.length() * delta:
		transitioned.emit(self, &"Idle")


#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
