extends State

@export var boar:CharacterBody2D = null
@export var boar_sprite:Sprite2D = null
@export var wall_ray:RayCast2D = null
@export var animator:AnimationPlayer = null
@export var wall_area:Area2D = null
@export var ouch_eye_sprite:Sprite2D = null
@onready var idle_timer:Timer = $IdleTimer

const BASE_IDLE_TIME:float = 0.4
var idle_time:float = BASE_IDLE_TIME

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	ouch_eye_sprite.visible = false
	boar.attack_state = false
	animator.play(&"RESET")
	boar.velocity = Vector2.ZERO
	
	if WolfStats.hunger_points > 0.0:
		idle_time = BASE_IDLE_TIME * (1 - boar.rage)
		if idle_time > 0:
			idle_timer.wait_time = idle_time
			idle_timer.start()
			#print("Idle time: ", idle_timer.wait_time)
		else:
			_on_idle_timer_timeout()
	else:
		transitioned.emit(self, &"Flee")

#-----------------------------------------
# Local Functions
#-----------------------------------------
func _on_death() -> void:
	if is_active: transitioned.emit(self, &"Death")

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_idle_timer_timeout() -> void:
	if not is_active: return
	if wall_area.get_overlapping_bodies().size() >= 3:
		if boar.is_wolf_nearby():
			#print("FLEE FROM WALL", wall_area.get_overlapping_bodies())
			transitioned.emit(self, &"Flee")
		else: transitioned.emit(self, &"Charge")
	else:
		transitioned.emit(self, &"Charge")

func _on_ouch_area_area_entered(_area: Area2D) -> void:
	if not is_active: return
	transitioned.emit(self, &"Flee")
