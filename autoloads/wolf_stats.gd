extends Node

signal hunger_filled(fill_amount:float)
signal hunger_depleted(deplete_amount:float)
signal deplete_tween_finished
signal fill_tween_finished

var wolf:CharacterBody2D = null
var wolf_camera_global_position:Vector2 = Vector2.ZERO
var hunger_points:float = 100.0
var max_hunger_points:float = 100.0
var hunger_drain_paused:bool = true
var eat_prey_gain:float = 15.0
var dash_energy_cost:float = 7.0
var dash_energy_end_value:float = -1
var hunger_bar_step:float = 0.05
var hunger_bar:ProgressBar = null
var deplete_tween:Tween = null
var deplete_tween_duration:float = 0.6
var fill_tween:Tween = null
var fill_tween_duration:float = 0.6
var fill_energy_end_value = -1
const default_fill_color:Color = Color(1.0, 0.361, 0.0, 0.831)
const dash_fill_color:Color = Color(0.426, 0.014, 0.0, 0.831)
const flash_fill_color:Color = Color(1.0, 1.0, 1.0, 1.0)
#const default_empty_color:Color = Color(0.357, 0.0, 0.016, 0.569)
var flash_tween:Tween = null
#var dash_flash_tween:Tween = null
var global_position:Vector2 = Vector2.ZERO
var velocity:Vector2 = Vector2.ZERO
enum STATE {
	INACIVE, SLOW_DRAIN, DASH_DRAIN, FILLING
}
var hunger_bar_state:STATE = STATE.INACIVE

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _ready() -> void:
	deplete_tween_finished.connect(_on_deplete_tween_finished)
	fill_tween_finished.connect(_on_fill_tween_finished)

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("attack"):
		#pass

func _physics_process(delta: float) -> void:
	if hunger_points <= 0 and hunger_drain_paused == false:
		var got_scene:Node = get_tree().current_scene
		if got_scene.name == "MainLevel":
			hunger_drain_paused = true
			get_tree().current_scene._on_death()
		#hunger_points = max_hunger_points
	if hunger_drain_paused: return
	deplete_hunger(hunger_bar_step * delta * Engine.physics_ticks_per_second)

#-----------------------------------------
# Local Functions
#-----------------------------------------
func _set_hunger_points(new_value:float) -> void:
	if new_value < hunger_points:
		hunger_depleted.emit(new_value)
	elif new_value > hunger_points:
		hunger_filled.emit(new_value)
	
	hunger_points = new_value

func set_hunger_bar(bar:ProgressBar) -> void:
	hunger_bar = bar
	hunger_bar.max_value = max_hunger_points
	hunger_bar.step = hunger_bar_step

func fill_hunger(amount:float=eat_prey_gain) -> void:
	if amount < hunger_bar_step: return
	if hunger_points >= max_hunger_points: return
	var remaining_dash_cost:float = 0
	if dash_energy_end_value >= 0:
		remaining_dash_cost = hunger_points - dash_energy_end_value
		dash_energy_end_value = -1
	if deplete_tween:
		deplete_tween.kill()
	
	var additional_energy:float = 0
	if fill_energy_end_value >= 0:
		additional_energy = fill_energy_end_value - hunger_points
		fill_energy_end_value = -1
	if fill_tween:
		fill_tween.kill(); fill_tween = null
	
	var safe_amount:float = amount - remaining_dash_cost + additional_energy
	safe_amount = clamp(safe_amount, hunger_bar_step, max_hunger_points - hunger_points)
	var target_amount:float = hunger_points + safe_amount
	
	fill_tween = create_tween()
	fill_tween.set_trans(Tween.TRANS_SINE)
	fill_tween.set_ease(Tween.EASE_OUT)
	fill_tween.tween_method(_set_hunger_points, hunger_points, target_amount, fill_tween_duration)
	fill_tween.tween_callback(fill_tween_finished.emit)
	
	if flash_tween: flash_tween.kill()
	flash_tween = create_tween()
	flash_tween.set_trans(Tween.TRANS_SINE)
	flash_tween.set_ease(Tween.EASE_OUT)
	flash_tween.tween_method(set_hunger_bar_fill_color,flash_fill_color,default_fill_color,0.5)
	hunger_bar_state = STATE.FILLING


func set_hunger_bar_fill_color(fill_color:Color) -> void:
	if not hunger_bar: return
	var flash_box:StyleBoxFlat = hunger_bar.get_theme_stylebox("fill")
	flash_box.bg_color = fill_color


func deplete_hunger(amount:float=hunger_bar_step) -> void:
	if hunger_points <= 0: return
	var safe_amount:float = clampf(amount, hunger_bar_step, hunger_points)
	if amount > hunger_bar_step:
		pass
		#dash_drain()
	else:
		_set_hunger_points(hunger_points - safe_amount)

func dash_drain(amount:float=dash_energy_cost) -> void:
	if hunger_bar_state == STATE.FILLING: return
	hunger_drain_paused = true
	var drain_amount:float = amount
	if fill_energy_end_value >= 0:
		drain_amount = drain_amount + (fill_energy_end_value - hunger_points)
		fill_energy_end_value = -1
	if fill_tween:
		fill_tween.kill(); fill_tween = null
	
	dash_energy_end_value = clamp(hunger_points - drain_amount, 0, max_hunger_points)
	
	deplete_tween = create_tween()
	deplete_tween.set_trans(Tween.TRANS_SINE)
	deplete_tween.set_ease(Tween.EASE_OUT)
	deplete_tween.tween_method(_set_hunger_points, hunger_points, dash_energy_end_value, deplete_tween_duration)
	deplete_tween.tween_callback(deplete_tween_finished.emit)
	
	if flash_tween: flash_tween.kill()
	flash_tween = create_tween()
	flash_tween.set_trans(Tween.TRANS_SINE)
	flash_tween.set_ease(Tween.EASE_OUT)
	flash_tween.tween_method(set_hunger_bar_fill_color,dash_fill_color,default_fill_color,0.5)
	hunger_bar_state = STATE.DASH_DRAIN

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_deplete_tween_finished() -> void:
	hunger_drain_paused = false
	dash_energy_end_value = -1
	hunger_bar_state = STATE.SLOW_DRAIN

func _on_fill_tween_finished() -> void:
	hunger_drain_paused = false
	fill_energy_end_value = -1
	hunger_bar_state = STATE.SLOW_DRAIN

func _on_global_position_changed(new_position:Vector2) -> void:
	global_position = new_position
