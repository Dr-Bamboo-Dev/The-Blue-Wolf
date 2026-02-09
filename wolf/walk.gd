extends WolfState

var step_sound_rate:int = 15
var time_to_step_sound:int = 0

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	animator.play(&"walk")

func exit() -> void:
	step_sound_rate = 15
	time_to_step_sound = 0

func input_update(event:InputEvent) -> void:
	if event.is_action_pressed(&"attack"):
		transitioned.emit(self, &"Dash")

func update(_delta:float) -> void:
	if wolf.win_condition_met:
		transitioned.emit(self, &"Howl")
	
	if WolfStats.hunger_points == 0.0:
		transitioned.emit(self, &"Dead")
	elif wolf.input_vector.length() == 0.0:
		transitioned.emit(self, &"Idle")

func physics_update(_delta:float) -> void:
	wolf.update_move_vector()
	wolf.velocity = wolf.move_vector + wolf.shove_vector
	wolf.move_and_slide()
	
	if time_to_step_sound <= 0:
		time_to_step_sound = step_sound_rate
		AudioManager.play_sfx(&"step", -15)
	else:
		time_to_step_sound -= 1

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
