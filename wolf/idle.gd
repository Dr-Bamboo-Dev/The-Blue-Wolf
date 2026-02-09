extends WolfState

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	wolf.velocity = Vector2.ZERO
	animator.play(&"idle")

func input_update(event:InputEvent) -> void:
	if event.is_action_pressed("attack"):
		transitioned.emit(self, &"Attack")

func update(_delta:float) -> void:
	if wolf.win_condition_met:
		transitioned.emit(self, &"Howl")
	
	if WolfStats.hunger_points == 0.0:
		transitioned.emit(self, &"Dead")
	elif wolf.input_vector.length() > 0.0:
		transitioned.emit(self, &"Walk")

func physics_update(_delta:float) -> void:
	wolf.velocity = wolf.shove_vector
	wolf.move_and_slide()

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
