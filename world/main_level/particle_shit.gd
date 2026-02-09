extends Node2D

signal particle_test_complete

var tests_complete:int = 0
var initial_child_count:int
@onready var chomp_particles:GPUParticles2D = $ChompParticles/GPUChomp
@onready var gem_collect_effect:Node2D = $GemCollectEffect/GemParticles


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	initial_child_count = get_child_count()
	chomp_particles.finished.connect(_on_test_complete)
	gem_collect_effect.finished.connect(_on_test_complete)

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_test_complete() -> void:
	tests_complete += 1
	print("Particle test complete: ", tests_complete)
	if tests_complete == initial_child_count:
		particle_test_complete.emit()
