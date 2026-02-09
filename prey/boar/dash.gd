extends State

@export var boar:CharacterBody2D = null
@export var animator:AnimationPlayer = null
@export var wall_ray:RayCast2D = null
@export var acceleration_curve:Curve = null
@export var ouch_eye_sprite:Sprite2D = null
@export var boar_gallop:AudioStreamPlayer2D = null
@export var boar_thud:AudioStreamPlayer2D = null
@onready var gallop_rate:Timer = $GallopRate
var acceleration_tween:Tween = null
const BASE_ACCELERATION_TIME:float = 1.0

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	ouch_eye_sprite.visible = false
	boar.aim_at_wolf()
	boar.attack_state = true
	animator.play("dash")
	
	var acceleration_time:float = BASE_ACCELERATION_TIME - boar.rage + 0.1
	#print("Acceleration time: ", acceleration_time)
	acceleration_tween = create_tween()
	acceleration_tween.set_ease(Tween.EASE_IN)
	acceleration_tween.set_trans(Tween.TRANS_LINEAR)
	acceleration_tween.tween_method(set_speed,0.0, 1.0, acceleration_time)
	AudioManager.play_sfx(&"gallop", -10)
	gallop_rate.start()

func exit() -> void:
	acceleration_tween.kill()
	gallop_rate.stop()

func physics_update(_delta:float) -> void:
	if WolfStats.hunger_points > 0.0:
		if wall_ray.is_colliding():
			var strength = boar.shake_strength_from_speed(boar.speed)
			Camera.screen_shake(-boar.face_direction, strength, 0.3)
			transitioned.emit(self,&"Idle")
			boar_thud.pitch_scale = randf_range(1.5, 1.8)
			boar_thud.play()
		else:
			boar.dash_forward(boar.speed)
	else:
		transitioned.emit(self, &"Flee")

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
func _on_ouch_area_area_entered(_area: Area2D) -> void:
	if not is_active: return
	if boar.speed < 666.0:
		transitioned.emit(self, &"Flee")

func _on_gallop_rate_timeout() -> void:
	#AudioManager.play_sfx(&"gallop", -10)
	boar_gallop.pitch_scale = randf_range(0.9, 1.0)
	boar_gallop.play()
