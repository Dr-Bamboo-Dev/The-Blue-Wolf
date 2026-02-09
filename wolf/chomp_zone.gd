extends Area2D

var chomp_positions:Dictionary[StringName, float] = {
	"left": -57,
	"right": 57
}
var enabled:bool = false : set = enable
@onready var chomp_shape: CollisionShape2D = $ChompShape
@onready var chomp_duration: Timer = $ChompDuration


#-----------------------------------------
# Built in Functions
#-----------------------------------------


#-----------------------------------------
# Local Functions
#-----------------------------------------
func enable(state:bool=true) -> void:
	enabled = state
	chomp_shape.disabled = !state

func set_chomp_position(pos:StringName) -> void:
	chomp_shape.position.x = chomp_positions[pos]


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_chomp_duration_timeout() -> void:
	chomp_shape.disabled = true
