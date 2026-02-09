extends Node2D

## How low the wolf hp has to get before the effect starts to become visible.
@export_range(0.0, 100.0, 1.0) var low_health_max:float = 33.0
@export_range(0.0, 100.0, 1.0) var dire_health_max:float = 10.0
## Opacity of effect which ranges from 0.0 to 1.0.
var opacity:float = 0.0 : set = set_opacity, get = get_opacity
var raduis:float = 0.8 : set = set_radius, get = get_raduis
var smooth:float = 0.78 : set = set_smooth, get = get_smooth
@onready var aura_rect: ColorRect = $AuraRect

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _process(_delta: float) -> void:
	var wolf_hp:float = WolfStats.hunger_points
	opacity = clamp(remap(wolf_hp, 0.0, low_health_max, 1.0, 0.0), 0.0, 1.0)
	raduis = clamp(remap(wolf_hp, 0.0, dire_health_max, 0.6, 0.8), 0.6, 0.8)
	smooth = clamp(remap(wolf_hp, 0.0, dire_health_max-5, 1.13, 0.78), 0.78, 1.13)
	#print(wolf_hp)

#-----------------------------------------
# Local Functions
#-----------------------------------------
#-------- Opacity -----------
func set_opacity(new_opacity) -> void:
	new_opacity = clamp(new_opacity, 0.0, 1.0)
	opacity = new_opacity
	aura_rect.material.set_shader_parameter("opacity", new_opacity)

func get_opacity() -> float:
	return aura_rect.material.get_shader_parameter("opacity")
	
#-------- Radius -----------
func set_radius(new_raduis:float) -> void:
	new_raduis = clamp(new_raduis, 0.1, 0.8)
	raduis = new_raduis
	aura_rect.material.set_shader_parameter("_Radius", new_raduis)

func get_raduis() -> float:
	return aura_rect.material.get_shader_parameter("_Radius")

#-------- Smooth -----------
func set_smooth(new_smooth:float) -> void:
	new_smooth = clamp(new_smooth, 0.0, 2.0)
	smooth = new_smooth
	aura_rect.material.set_shader_parameter("_Smoot", new_smooth)

func get_smooth() -> float:
	return aura_rect.material.get_shader_parameter("_Smoot")

#-----------------------------------------
# Signal Functions
#-----------------------------------------
