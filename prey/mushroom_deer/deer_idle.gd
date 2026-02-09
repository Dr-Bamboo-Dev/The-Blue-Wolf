extends State
class_name DeerIdle

var move_direction:Vector2 = Vector2.ZERO
var wander_time:float = 0.0

@export var mushroom_deer:CharacterBody2D = null
@export var deer_animator:AnimationPlayer = null
@export var move_speed:float = 50.0
@export var velocity:float = 3.33


#-----------------------------------------
# Built in Functions
#-----------------------------------------
func enter() -> void:
	deer_animator.play("walk", -1, 1.0)
	randomize_wander()

func exit() -> void:
	pass

func update(delta:float) -> void:
	if wander_time > 0:
		wander_time = move_toward(wander_time, 0.0, delta)
	else:
		randomize_wander()

func physics_update(delta:float) -> void:
	if mushroom_deer:
		var adj_speed = move_speed * delta * 60
		var adj_velocity = velocity * delta * 60
		var new_move_direction:Vector2 = Vector2.ZERO
		var new_move_vector:Vector2 = Vector2.ZERO
		
		# Avoid other deer
		new_move_direction = (move_direction + owner.away_vector).normalized()
		
		new_move_vector = mushroom_deer.velocity.move_toward(new_move_direction * adj_speed, adj_velocity)
		mushroom_deer.velocity = new_move_vector
	
	#if Engine.get_physics_frames() > 600:
		#transitioned.emit(self, "DeerFlee")

#-----------------------------------------
# Local Functions
#-----------------------------------------
func randomize_wander() -> void:
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1.5, 3)

func _scare_zone_entered() -> void:
	transitioned.emit(self, "DeerFlee")

func _got_chomped() -> void:
	transitioned.emit(self, "DeerChomped")

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_deer_vis_notifier_screen_exited() -> void:
	transitioned.emit(self, "DeerInactive")
