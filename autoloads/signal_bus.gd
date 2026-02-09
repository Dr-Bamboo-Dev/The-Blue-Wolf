extends Node

signal mole_switches_red
signal mole_switches_blue
signal touch_joystick_output_changed(new_value:Vector2)

var red_mole_switch_state:bool = true : 
	set = set_red_bole_switch_state

var eating_yummers:bool = false :
	set = set_eating_yummers

var touch_joystick_vector:Vector2 = Vector2.ZERO :
	set = set_touch_joystick_vector

#-----------------------------------------
# Inherited Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------
func set_red_bole_switch_state(new_state:bool) -> void:
	red_mole_switch_state = new_state
	if new_state: mole_switches_red.emit()
	else: mole_switches_blue.emit()

func set_eating_yummers(new_value:bool) -> void:
	eating_yummers = new_value

func transmit_touch_joystick_output(new_value:Vector2) -> void:
	touch_joystick_vector = new_value
	#touch_joystick_output_changed.emit(new_value)

func set_touch_joystick_vector(new_vec:Vector2) -> void:
	touch_joystick_vector = new_vec
	touch_joystick_output_changed.emit(new_vec)


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_mole_switch_update(new_state:bool) -> void:
	#print("New state: ", new_state)
	if new_state == red_mole_switch_state: return
	red_mole_switch_state = new_state
	if new_state: mole_switches_red.emit()
	else: mole_switches_blue.emit()

func _on_wolf_at_yummers() -> void:
	eating_yummers = true

func _on_wolf_done_eating() -> void:
	eating_yummers = false
