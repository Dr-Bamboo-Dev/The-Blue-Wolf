extends WolfState

var howl_delay:int = 30
var time_to_howl:int = 30
var howl_played:bool = false

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	time_to_howl = howl_delay
	#AudioManager.play_sfx(&"wolf_ascension")
	animator.play(&"howl")

func physics_update(_delta:float) -> void:
	if howl_played: return
	if time_to_howl <= 0:
		AudioManager.play_sfx(&"wolf_howl")
		howl_played = true
	else:
		time_to_howl -= 1

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
