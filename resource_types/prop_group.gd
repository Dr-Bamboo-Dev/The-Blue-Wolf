@tool
extends Resource
class_name PropGroup

@export var scene_path:String = ""
@export var root_base_name:String = ""
@export var tree_path:NodePath = ""
@export var positions_in_scene:PackedVector2Array = []
func to_dict() -> Dictionary:
	return {
		"scene_path": scene_path,
		"root_base_name": root_base_name,
		"tree_path": tree_path,
		"positions_in_scene": positions_in_scene
	}
#-----------------------------------------
# Inherited Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
