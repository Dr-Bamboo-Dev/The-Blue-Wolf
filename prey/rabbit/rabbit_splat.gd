extends Node2D

@onready var splat_particles:CPUParticles2D = $SplatParticles


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	splat_particles.emitting = true

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_splat_particles_finished() -> void:
	queue_free()
