extends State

@onready var level_ysort:Node2D = get_tree().current_scene.get_node("YSort")
@onready var death_animator:AnimationPlayer = $DeathAnimator
@onready var ham_delay:Timer = $HamDelay
var ham:PackedScene = preload("res://items/ham/ham.tscn")
@export var boar:CharacterBody2D = null
@export var boar_sprite:Sprite2D = null
@export var ouch_eye_sprite:Sprite2D = null
@export var ouch_area:Area2D = null
@export var boar_animator:AnimationPlayer = null

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	AudioManager.kill_all_tracks(1.0)
	ouch_area.set_deferred("monitoring", false)
	boar.attack_state = false
	ouch_eye_sprite.visible = true
	boar_animator.play("panic") # 1.0 seconds long
	
	#death_animator.play("explode") # 0.5 seconds long
	#death_timer.start()
	#spawn_ham(50)

#-----------------------------------------
# Local Functions
#-----------------------------------------
func spawn_ham(quantity:int=1, spread:float=1, launch_force:float=2000) -> void:
	print("Spawning ", quantity, " ham...")
	var offset_pos:Vector2 = Vector2.ZERO
	for each in quantity:
		var new_ham:RigidBody2D = ham.instantiate()
		new_ham.global_position = boar.global_position + offset_pos
		offset_pos = Vector2(randf_range(-spread,spread)*1.5, randf_range(-spread,spread))
		level_ysort.add_child(new_ham)
		new_ham.apply_central_impulse(boar.global_position.direction_to(
			new_ham.global_position) * 
			launch_force * randf_range(0.1, 1))

func spawn_explode_particles() -> void:
	var new_explode:Node2D = boar.explode_particles.instantiate()
	new_explode.global_position = boar.global_position + Vector2(0.0, 10.0)
	new_explode.z_index += 1
	level_ysort.add_child(new_explode)

func trigger_explode_sound() -> void:
	AudioManager.play_sfx(&"boar_explode")

func trigger_explode_screen_shake() -> void:
	Camera.screen_shake(Vector2.DOWN,15,0.4)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_boar_animator_animation_finished(anim_name: StringName) -> void:
	if is_active:
		if anim_name == "panic":
			SignalBus.red_mole_switch_state = true
			spawn_explode_particles()
			ouch_eye_sprite.visible = false
			death_animator.play("shrink")
			spawn_ham(50)
			ham_delay.start(0.1)


func _on_ham_delay_timeout() -> void:
	boar.queue_free()
