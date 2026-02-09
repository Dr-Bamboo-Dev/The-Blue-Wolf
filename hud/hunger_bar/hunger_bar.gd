extends ProgressBar

signal deplete_tween_finished

var default_step_size:float = step
var deplete_tween:Tween = null

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _ready() -> void:
	WolfStats.set_hunger_bar(self)
	WolfStats.hunger_filled.connect(fill_hunger_bar)
	WolfStats.hunger_depleted.connect(deplete_hunger_bar)
	deplete_tween_finished.connect(WolfStats._on_deplete_tween_finished)


#-----------------------------------------
# Local Functions
#-----------------------------------------
func _set_hunger_bar(new_value:float) -> void:
	value = new_value

func _set_bar_step(new_size:float) -> void:
	step = new_size

func fill_hunger_bar(new_value:float=step) -> void:
	#This is where fill tween can go
	if value >= max_value: return
	_set_hunger_bar(new_value)
#
func deplete_hunger_bar(new_value:float=step) -> void:
	#if (deplete_tween != null) and  deplete_tween.is_running(): return
	if value <= 0: return
	_set_hunger_bar(new_value)



#-----------------------------------------
# Signal Functions
#-----------------------------------------
