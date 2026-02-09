extends Node
class_name State

@warning_ignore("unused_signal")
signal transitioned(old_state:State, new_state:StringName)
var is_active:bool = false

#-----------------------------------------
# Built in Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------
func enter() -> void:
	pass

func exit() -> void:
	pass

@warning_ignore("unused_parameter")
func input_update(event:InputEvent) -> void:
	pass

@warning_ignore("unused_parameter")
func update(delta:float) -> void:
	pass

@warning_ignore("unused_parameter")
func physics_update(delta:float) -> void:
	pass


#-----------------------------------------
# Signal Functions
#-----------------------------------------
