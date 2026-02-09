extends State

@export var boar:CharacterBody2D = null
@export var animator:AnimationPlayer = null
@export var ouch_eye_sprite:Sprite2D = null
@export var boar_grunt:AudioStreamPlayer2D = null
var aim_direction:Vector2 = Vector2.ZERO

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	ouch_eye_sprite.visible = false
	boar.aim_at_wolf()
	animator.play("charge")
	#AudioManager.play_sfx(&"boar_grunt",-5)
	boar_grunt.pitch_scale = randf_range(0.8, 1.2)
	boar_grunt.play()

#-----------------------------------------
# Local Functions
#-----------------------------------------
func _on_death() -> void:
	if is_active: transitioned.emit(self, &"Death")

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_boar_animator_animation_finished(anim_name: StringName) -> void:
	if not is_active: return
	if anim_name != &"charge": return
	transitioned.emit(self,&"Dash")

func _on_ouch_area_area_entered(_area: Area2D) -> void:
	if not is_active: return
	transitioned.emit(self, &"Flee")
