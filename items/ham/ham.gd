extends Node2D

var ham_particles:PackedScene = preload("res://items/ham/ham_particles.tscn")
@onready var ham_area: Area2D = $HamArea

#-----------------------------------------
# Inherited Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_ham_eaten(area: Area2D) -> void:
	if area.name == "ChompZone":
		var level_ysort:Node2D = get_tree().current_scene.get_node("YSort")
		var new_ham_particles:Node2D = ham_particles.instantiate()
		new_ham_particles.global_position = global_position
		level_ysort.add_child(new_ham_particles)
		queue_free()


func _on_edible_timer_timeout() -> void:
	ham_area.set_deferred("monitorable", true)
	ham_area.set_deferred("monitoring", true)
