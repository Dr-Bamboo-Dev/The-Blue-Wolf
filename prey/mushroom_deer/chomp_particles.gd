extends Node2D

@onready var chomp_cpu: CPUParticles2D = $ChompCPU

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _ready() -> void:
	chomp_cpu.emitting = true

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_chomp_cpu_finished() -> void:
	queue_free()
