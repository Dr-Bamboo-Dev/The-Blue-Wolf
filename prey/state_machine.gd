extends Node
class_name StateMachine

signal state_changed(new_state:StringName)

@export var initial_state:State = null

var current_state:State
var states:Dictionary[StringName, State] = {}

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transitioned.connect(_on_state_transitioned)
	if initial_state:
		initial_state.is_active = true
		initial_state.enter()
		current_state = initial_state

func _unhandled_input(event:InputEvent) -> void:
	if current_state:
		current_state.input_update(event)

func _process(delta:float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta:float) -> void:
	if current_state:
		current_state.physics_update(delta)


#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
# Change state request from current state.
func _on_state_transitioned(old_state:State, new_state:StringName) -> void:
	if old_state.name == new_state: return
	
	if states.has(new_state): 
		current_state = states.get(new_state)
		old_state.exit()
		old_state.is_active = false
		current_state.is_active = true
		current_state.enter()
		state_changed.emit(new_state)
	else: 
		push_error("State '", new_state, "' not found!")
	
	
