@tool
extends Resource
class_name PropSave

@export var prop_groups:Dictionary[String,PropGroup]

#-----------------------------------------
# Inherited Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------
func to_dict() -> Dictionary:
	var pure_dict:Dictionary[String,Dictionary]
	for group in prop_groups:
		pure_dict[group] = prop_groups[group].to_dict()
	return pure_dict

#-----------------------------------------
# Signal Functions
#-----------------------------------------
