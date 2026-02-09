@tool
extends Node2D
class_name GemSpinner

## Editor button used to update the base positions of the turn table markers.
@export_tool_button("Update Base Positions", "ShapeCast2D") var set_gem_pos:Callable = update_base_position
## The number of equally-spaced gem positions to be spun.
@export_range(1.0, 12.0) var gem_pos_count:int = 3
## The distance from the turn table center the gems are positioned at.
@export_range(0.0, 500.0) var gem_pos_radius:float = 100.0
## The rotation of the turn table in degrees.
@export_range(0.0, 360.0) var gems_rotation:float = 0.0 # : set = set_gems_rotation
## The turn table that holds the position markers.
@onready var turn_table:Node2D = $TurnTable
## The Node2D that holds the gem sprites. (It does not spin.)
@onready var gem_sprites_holder:Node2D = $GemSprites
## Base positions of turn table markers (not accounting for turn table rotation).
var gem_dir_vecs:PackedVector2Array
## Gems that are spun using the turn table marker positions.
var gem_sprites:Array[Node]
## Markers that the gems' positions are matched to.
var gem_pos_markers:Array[Node]

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	gem_pos_markers = turn_table.get_children()
	gem_dir_vecs = calculate_gem_angle_vecs(gem_pos_count).duplicate()
	gem_sprites = gem_sprites_holder.get_children()

#func _unhandled_input(event: InputEvent) -> void:
	#if not Engine.is_editor_hint():
		#if event.is_echo(): return
		#if event is InputEventKey and event.keycode == KEY_Q and event.is_pressed():
			#print(gem_dir_vecs)

func _process(_delta: float) -> void:
	var index:int = 0
	for sprite in gem_sprites:
		sprite.position = gem_pos_markers[index].global_position - global_position
		index += 1
	
	index = 0
	for marker in gem_pos_markers:
		marker.position = gem_dir_vecs[index] * gem_pos_radius
		index += 1
	if turn_table != null:
		turn_table.rotation_degrees = gems_rotation

#-----------------------------------------
# Local Functions
#-----------------------------------------
## Used to calculate base position vectors from evenly divided angles.
func calculate_gem_angle_vecs(gem_count:int=3) -> PackedVector2Array:
	if gem_count < 1: push_error("Cannot calculate fewer than one position!"); return [Vector2.ZERO]
	var angle_vecs:PackedVector2Array
	var angles_deg:PackedFloat32Array = ( func() -> PackedFloat32Array:
		var return_angles:PackedFloat32Array
		for each in gem_count:
			var new_angle:float = (360.0/gem_count) * each
			return_angles.append(new_angle)
		return return_angles ).call()
	
	for angle in angles_deg:
		var new_vec:Vector2 = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle))).normalized()
		angle_vecs.append(new_vec)
	
	return angle_vecs

## Updates the base positions of the turn table markers.
func update_base_position() -> void:
	gem_dir_vecs = calculate_gem_angle_vecs(gem_pos_count)
	#print(gem_dir_vecs)



# Setter for gems_rotation (positive rotation values only)
#func set_gems_rotation(new_rotation_deg:float) -> void:
	#var valid_rotation = abs(new_rotation_deg) % 360
	#gems_rotation = valid_rotation

#-----------------------------------------
# Signal Functions
#-----------------------------------------
