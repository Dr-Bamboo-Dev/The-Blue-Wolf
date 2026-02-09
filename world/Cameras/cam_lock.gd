extends Node2D

var cam_lock_active:bool = false
@onready var cam_lock_cam: Camera2D = $CamLockCam

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _process(delta: float) -> void:
	if cam_lock_active:
		cam_lock_cam.global_position = WolfStats.wolf_camera_global_position

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_area_2d_body_entered(body: Node2D) -> void:
	cam_lock_active = true
	cam_lock_cam.enabled = true
	cam_lock_cam.global_position = WolfStats.wolf_camera_global_position
	cam_lock_cam.make_current()
	print("wolf in")


func _on_area_2d_body_exited(body: Node2D) -> void:
	cam_lock_active = false
	cam_lock_cam.enabled = false
	cam_lock_cam.global_position = global_position
	print("wolf out")
