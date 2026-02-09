extends Node

## Wolf camera position
var cam_position:Vector2 = Vector2.ZERO
## The dimensions of the render zone
var render_size:Vector2 = Vector2(500,500)
## The actual render zone in absolute coordinates
var render_zone:PackedVector2Array = [Vector2.ZERO,Vector2.ZERO]

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	cam_position = WolfStats.wolf_camera_global_position
	render_zone = [cam_position - render_size/2, cam_position + render_size/2]

func _process(_delta: float) -> void:
	cam_position = WolfStats.wolf_camera_global_position
	render_zone = [cam_position - render_size/2, cam_position + render_size/2]
	


#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
