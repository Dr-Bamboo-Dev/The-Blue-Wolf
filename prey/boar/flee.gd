extends State

@export var boar:CharacterBody2D = null
@export var wall_ray:RayCast2D = null
@export var animator:AnimationPlayer = null
@export var acceleration_curve:Curve = null
@export var ouch_eye_sprite:Sprite2D = null
@export var attack_shape:CollisionShape2D = null
@export var boar_gallop:AudioStreamPlayer2D = null
@onready var gallop_rate:Timer = $GallopRate
var acceleration_tween:Tween = null
var flee_frames:int = 0

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	attack_shape.set_deferred("disabled",true)
	boar.set_wolf_collision(false)
	boar.aim_at_point(boar.random_flee_direction())
	boar.attack_state = false
	animator.speed_scale = 2.5
	animator.play("dash")
	
	acceleration_tween = create_tween()
	acceleration_tween.set_ease(Tween.EASE_IN)
	acceleration_tween.set_trans(Tween.TRANS_LINEAR)
	acceleration_tween.tween_method(set_speed,0.0,1.0,1.0)
	gallop_rate.start()

func exit() -> void:
	animator.speed_scale = 1.0
	attack_shape.set_deferred("disabled",false)
	boar.set_wolf_collision(true)
	flee_frames = 0
	ouch_eye_sprite.visible = false
	acceleration_tween.kill()
	gallop_rate.stop()

func physics_update(_delta:float) -> void:
	if wall_ray.is_colliding():
		if flee_frames >= 3:
			transitioned.emit(self,&"Idle")
	else:
		boar.dash_forward(boar.speed)
	flee_frames += 1

#-----------------------------------------
# Local Functions
#-----------------------------------------
func set_speed(curve_offset:float) -> void:
	boar.speed = acceleration_curve.sample(curve_offset) * boar.max_speed

func _on_death() -> void:
	if is_active: transitioned.emit(self, &"Death")

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_gallop_rate_timeout() -> void:
	#AudioManager.play_sfx(&"gallop", -10, 1.4)
	boar_gallop.pitch_scale = randf_range(0.9, 1.1)
	boar_gallop.play()
