extends State
class_name DeerFlee

var flee_direction:Vector2 = Vector2.ZERO
var flee_speed:float = 300
@export var mushroom_deer:CharacterBody2D = null
@export var deer_animator:AnimationPlayer = null
@onready var flee_extend_time:Timer = $FleeExtendTime


#-----------------------------------------
# Built in Functions
#-----------------------------------------
func enter() -> void:
	deer_animator.play("walk", -1, 2.0)
	mushroom_deer.velocity = Vector2.ZERO

func exit() -> void:
	pass

func physics_update(delta:float) -> void:
	
	
	flee_direction = WolfStats.global_position.direction_to(mushroom_deer.global_position)
	
	#Testing
	flee_direction = (flee_direction + owner.away_vector).normalized()
	
	mushroom_deer.velocity = flee_direction * flee_speed * delta * 60

#-----------------------------------------
# Local Functions
#-----------------------------------------
func _scare_zone_entered() -> void:
	flee_extend_time.stop()

func _scare_zone_exited() -> void:
	if flee_extend_time.is_stopped():
		flee_extend_time.start()

func _got_chomped() -> void:
	transitioned.emit(self, "DeerChomped")

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_flee_extend_time_timeout() -> void:
	transitioned.emit(self, "DeerIdle")

func _on_deer_vis_notifier_screen_exited() -> void:
	transitioned.emit(self, "DeerInactive")
