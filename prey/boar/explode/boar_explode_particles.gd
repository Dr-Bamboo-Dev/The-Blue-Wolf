extends Node2D

@onready var emitter: CPUParticles2D = $Emitter


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	emitter.emitting = true

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
