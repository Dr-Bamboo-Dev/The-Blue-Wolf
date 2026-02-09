extends Node

var current_camera:Camera2D = null

#-----------------------------------------
# Inherited Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------
func screen_shake(direction:Vector2, magnitude:float, duration:float=0.2) -> void:
	if current_camera == null: push_error("Current camera is null!"); return
	current_camera.screen_shake(direction, magnitude, duration)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
