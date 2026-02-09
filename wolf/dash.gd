extends WolfState


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	animator.animation_finished.connect(_on_animator_animation_finished)
	chomp_zone.area_entered.connect(_on_area_entered_chomp_zone)

func enter() -> void:
	WolfStats.dash_drain()
	AudioManager.play_sfx(&"dash")
	animator.play(&"dash")
	chomp_zone.enabled = true

func update(_delta:float) -> void:
	if wolf.win_condition_met:
		transitioned.emit(self, &"Howl")
	
	if WolfStats.hunger_points == 0.0:
		transitioned.emit(self, &"Dead")

func physics_update(_delta:float) -> void:
	wolf.update_move_vector()
	wolf.velocity = (wolf.move_vector * wolf.dash_boost) + wolf.shove_vector
	wolf.move_and_slide()

func exit() -> void:
	chomp_zone.enabled = false


#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_animator_animation_finished(anim_name:StringName) -> void:
	if not is_active: return
	if anim_name != &"dash": return
	if wolf.input_vector.length() == 0.0:
		transitioned.emit(self, &"Idle")
	else:
		transitioned.emit(self, &"Walk")

func _on_area_entered_chomp_zone(_body:Node2D) -> void:
	if not is_active: return
	WolfStats.fill_hunger()
	AudioManager.kill_all_sfx(&"dash")
	AudioManager.play_sfx(&"wet_chomp")
