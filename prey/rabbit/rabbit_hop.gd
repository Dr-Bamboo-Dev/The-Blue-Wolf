extends State

@export var startup_acceleration_curve:Curve = null
@export var hop_acceleration_curve:Curve = null
@export var rabbit:CharacterBody2D = null
@export var rabbit_animator:AnimationPlayer = null

const hop_max_speed:float = 510.0 # OG: 300.0
var hop_speed:float = 0.0
var hop_direction:Vector2 = Vector2.RIGHT
var startup_prog:float = 0.0
var startup_mult:float = 0.0



#-----------------------------------------
# Inherited Functions
#-----------------------------------------


func enter() -> void:
	rabbit_animator.play(&"hop")

func physics_update(delta:float) -> void:
	hop_update(delta)
	rabbit.velocity = hop_direction * hop_speed
	rabbit.move_and_slide()
	startup_mult_step()
	#print(hop_speed)

#-----------------------------------------
# Local Functions
#-----------------------------------------
func hop_update(delta) -> void:
	if not rabbit_animator.is_playing(): return
	if not rabbit_animator.current_animation == &"hop":
		hop_speed = 0.0
		return
	var anim_length:float = rabbit_animator.current_animation_length
	var anim_pos:float = rabbit_animator.current_animation_position
	var anim_progress:float = remap(anim_pos,0,anim_length,0,1)
	hop_speed = roundf(hop_acceleration_curve.sample(anim_progress) * hop_max_speed * delta * 60 * startup_mult)

func startup_mult_step() -> void:
	startup_prog = move_toward(
		startup_prog,startup_acceleration_curve.max_domain, get_physics_process_delta_time())
	startup_mult = startup_acceleration_curve.sample(startup_prog)


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_rabbit_vis_notifier_screen_exited() -> void:
	if is_active:
		transitioned.emit(self, &"RabbitInactive")

func _on_ouch_area_area_entered(_area: Area2D) -> void:
	if is_active:
		transitioned.emit(self, &"RabbitChomped")
