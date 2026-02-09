@tool
extends Node2D
class_name Prop

@export_tool_button("Initialize") var init_me:Callable = init_prop
@export_tool_button("Auto Set VisArea") var auto_vis_area = set_vis_area_size
#@export var prop_texture:Texture2D
const collision_layer_value:int = 2048
const collision_mask_value:int = 1536

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	if Engine.is_editor_hint():
		init_prop()
	else:
		$VisArea.area_entered.connect(_on_render_area_entered)
		$VisArea.area_exited.connect(_on_render_area_exited)
	_prop_ready()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if has_node("./PropSprite"):
			var prop_rect:Vector2i = Vector2i($PropSprite.get_rect().size)
			if prop_rect.x % 2 > 0:
				$PropSprite.offset.x = 0.5
			else: $PropSprite.offset.x = 0.0
			if prop_rect.y % 2 > 0:
				$PropSprite.offset.y = 0.5
			else: $PropSprite.offset.y = 0.0
	_prop_process(delta)

#-----------------------------------------
# Local Functions
#-----------------------------------------
func init_prop() -> void:
	#var children:Array[Node] = get_children()
	var scene_root:Node = get_tree().edited_scene_root
	if not has_node("./PropSprite"):
		var new_sprite:Sprite2D = Sprite2D.new()
		new_sprite.name = "PropSprite"
		add_child(new_sprite)
		new_sprite.owner = scene_root
		print("Added Sprite!")
	if not has_node("./VisArea"):
		var new_area:Area2D = Area2D.new()
		new_area.name = "VisArea"
		add_child(new_area)
		new_area.owner = scene_root
		print("Added VisArea!")
	if not has_node("./VisArea/AreaShape"):
		var new_shape:CollisionShape2D = CollisionShape2D.new()
		new_shape.name = "AreaShape"
		$VisArea.add_child(new_shape)
		new_shape.owner = scene_root
		new_shape.z_index = -1
		new_shape.debug_color = Color(0.949, 0.949, 0.949, 0.125)
		var new_rectangle:RectangleShape2D = RectangleShape2D.new()
		new_rectangle.size = Vector2(60,40)
		new_shape.shape = new_rectangle
		print("Added AreaShape!")
	if $VisArea.collision_layer != collision_layer_value:
		$VisArea.collision_layer = collision_layer_value
	if $VisArea.collision_mask != collision_mask_value:
		$VisArea.collision_mask = collision_mask_value

func _prop_ready() -> void:
	pass

func _prop_process(_delta: float) -> void:
	pass

func set_vis_area_size() -> void:
	if has_node("./VisArea/AreaShape"):
		var vis_shape:CollisionShape2D = $VisArea/AreaShape
		vis_shape.position = $PropSprite.position
		var new_rect:RectangleShape2D = RectangleShape2D.new()
		new_rect.size = $PropSprite.get_rect().size
		vis_shape.shape = new_rect
	

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_render_area_entered(_area:Area2D) -> void:
	if visible == false: visible = true

func _on_render_area_exited(_area:Area2D) -> void:
	if visible == true: visible = false
