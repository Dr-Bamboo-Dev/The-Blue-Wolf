@tool
extends Node2D

@export_tool_button("Save all Props") var prop_save_button:Callable = save_all_props
@export_tool_button("Load all Props") var prop_load_button:Callable = load_all_props

#-----------------------------------------
# Inherited Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------
func spawn_in_props() -> void:
	pass


# Save: Node type, name, tree path, scene position
func save_all_props() -> void:
	var scene_objects:Array[Node] = find_children("*","",true,false)
	var props:Array[Prop]
	for obj in scene_objects:
		if obj is Prop: props.append(obj)
	
	if props.size() < 1: push_warning("No Props found! Nothing to save. Aborting."); return
	
	var trees_save:PropGroup = PropGroup.new()
	trees_save.scene_path = "res://world/props/tree.tscn"
	trees_save.root_base_name = "Tree"
	trees_save.tree_path = "./Trees"
	for obj in props:
		if obj.scene_file_path == trees_save.scene_path:
			trees_save.positions_in_scene.append(obj.global_position)
	
	print(trees_save.scene_path)
	print(trees_save.root_base_name)
	print(trees_save.tree_path)
	print(trees_save.positions_in_scene)
	
	var props_save:PropSave = PropSave.new()
	props_save.prop_groups.set(trees_save.root_base_name, trees_save)
	
	ResourceSaver.save(props_save,"res://world/main_level/main_level_props.tres")
	#var save_the_trees:FileAccess = FileAccess.open("res://trees_save.json",FileAccess.WRITE)
	#save_the_trees.store_string(JSON.stringify(trees_save.to_dict()))

func load_all_props() -> void:
	var loaded_props:PropSave = ResourceLoader.load("res://world/main_level/main_level_props.tres")
	var tree_group:PropGroup = loaded_props.prop_groups["Tree"]
	#var loaded_dict:Dictionary[String,Dictionary] = loaded_props.to_dict()
	var g_base_name:String = tree_group.root_base_name
	var g_positions:PackedVector2Array = tree_group.positions_in_scene
	var g_node_path:String = tree_group.tree_path
	
	var scene_root:Node = get_tree().edited_scene_root
	var tree_tscn:PackedScene = load(tree_group.scene_path)
	var tree_num:int = 1
	#var new_trees:Array[Node]
	for pos in g_positions:
		var new_tree:Node2D = tree_tscn.instantiate()
		new_tree.name = str(g_base_name, tree_num); tree_num += 1
		new_tree.global_position = pos
		get_node(g_node_path).add_child(new_tree)
		new_tree.owner = scene_root
	
	#var json_boi:String = FileAccess.get_file_as_string("res://trees_save.json")
	#print(JSON.parse_string(json_boi))
	#var dick:Dictionary = JSON.parse_string(json_boi)
	#print(dick["scene_path"])


#class prop_save:
	#var scene_path:String = ""
	#var root_base_name:String = ""
	#var tree_path:NodePath = ""
	#var positions_in_scene:PackedVector2Array = []
	#func to_dict() -> Dictionary:
		#return {
			#"scene_path": scene_path,
			#"root_base_name": root_base_name,
			#"tree_path": tree_path,
			#"positions_in_scene": positions_in_scene
		#}


#-----------------------------------------
# Signal Functions
#-----------------------------------------
