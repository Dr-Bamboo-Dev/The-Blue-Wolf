@tool
extends Node2D

signal collected(type)

var is_collected:bool = false
var collect_effect:PackedScene = preload("res://items/gem/gem_collect_effect_2.tscn")
@export var gem_type:GameConst.gem_type = GameConst.gem_type.EMERALD

@onready var gem_sprite:Sprite2D = $GemSprite
@onready var collect_shape: CollisionShape2D = $CollectArea/CollectShape

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		gem_sprite.frame = gem_type
		collected.connect(GameProgress._on_gem_collected)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		gem_sprite.frame = gem_type

#-----------------------------------------
# Local Functions
#-----------------------------------------
func flash() -> void:
	gem_sprite.set_instance_shader_parameter("flashing", true)
	var flash_tween:Tween = create_tween()
	flash_tween.set_trans(Tween.TRANS_SINE)
	flash_tween.set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(gem_sprite, "modulate:a", 0.0, 0.5)
	flash_tween.tween_callback(queue_free).set_delay(1)
	
	var shrink_tween:Tween = create_tween()
	shrink_tween.set_trans(Tween.TRANS_SINE)
	shrink_tween.set_ease(Tween.EASE_OUT)
	shrink_tween.tween_property(gem_sprite, "scale", Vector2.ZERO, 0.7)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_collect_area_body_entered(_body: Node2D) -> void:
	if is_collected: return
	if not Engine.is_editor_hint():
		is_collected = true
		collected.emit(gem_type)
		var new_collect_effect:Node2D = collect_effect.instantiate()
		get_parent().add_child(new_collect_effect)
		new_collect_effect.global_position = global_position
		#new_collect_effect.emit_particles()
		flash()
		WolfStats.fill_hunger(100)
