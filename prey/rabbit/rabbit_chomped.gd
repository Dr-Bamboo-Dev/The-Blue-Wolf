extends State

@export var rabbit:CharacterBody2D = null
@export var rabbit_animator:AnimationPlayer = null
@export var ouch_area:Area2D = null
@export var ouch_shape:CollisionShape2D = null
var splat:PackedScene = preload("res://prey/rabbit/rabbit_splat.tscn")

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	ouch_area.set_deferred("monitorable",false)
	rabbit_animator.play(&"RESET")
	spawn_splat()
	rabbit.visible = false
	rabbit.queue_free()

#-----------------------------------------
# Local Functions
#-----------------------------------------
func spawn_splat() -> void:
	var new_splat:Node2D = splat.instantiate()
	new_splat.global_position = ouch_shape.global_position
	rabbit.get_parent().add_child(new_splat)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
