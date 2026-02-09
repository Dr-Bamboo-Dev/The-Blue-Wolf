extends StateMachine

var scare_zone_watchers:Array[Node] = []
@export var deer:CharacterBody2D = null
@export var deer_animator:AnimationPlayer

#-----------------------------------------
# Built in Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------
func start_scare() -> void:
	if current_state.has_method("_scare_zone_entered"):
		current_state._scare_zone_entered()

func stop_scare() -> void:
	if current_state.has_method("_scare_zone_exited"):
		current_state._scare_zone_exited()

func chomped() -> void:
	if current_state.has_method("_got_chomped"):
		current_state._got_chomped()

#-----------------------------------------
# Signal Functions
#-----------------------------------------
