extends Node2D

@onready var gem_particles:CPUParticles2D = $GemParticles


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	emit_particles()

#-----------------------------------------
# Local Functions
#-----------------------------------------
func emit_particles() -> void:
	gem_particles.emitting = true


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_gem_particles_finished() -> void:
	gem_particles.emitting = false
	await get_tree().create_timer(1).timeout
	queue_free()
