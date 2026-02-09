@tool
extends Node2D
class_name MoleSwitch

#static var red_up:bool = true
var self_up:bool = true
@export var self_color_red:bool = true
@onready var mole_animator:AnimationPlayer = $MoleAnimator
@onready var mole_sprite:Sprite2D = $MoleSprite
@onready var mole_body:StaticBody2D = $MoleBody
@onready var ouch_area:Area2D = $OuchArea

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		SignalBus.mole_switches_red.connect(_on_global_red_up)
		SignalBus.mole_switches_blue.connect(_on_global_blue_up)
		mole_sprite.material.set_shader_parameter("red_mode",self_color_red)
		instant_update_status()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		mole_sprite.material.set_shader_parameter("red_mode",self_color_red)

#-----------------------------------------
# Local Functions
#-----------------------------------------
func switch_animation(popup:bool) -> void:
	if popup: mole_animator.play("popup")
	else: mole_animator.play("duck")

func set_solid(new_state:bool) -> void:
	if new_state: mole_body.collision_layer = 4
	else: mole_body.collision_layer = 0

func set_up_status(new_status:bool) -> void:
	self_up = new_status
	switch_animation(new_status)
	set_solid(new_status)

func instant_set_up_status(new_status:bool) -> void:
	self_up = new_status
	if new_status:
		mole_animator.play("RESET")
		set_solid(true)
		ouch_area.call_deferred("set_monitoring",true)
	else:
		mole_animator.play("down")
		set_solid(false)
		ouch_area.call_deferred("set_monitoring",false)

func instant_update_status() -> void:
	if self_color_red: instant_set_up_status(SignalBus.red_mole_switch_state)
	else: instant_set_up_status(not SignalBus.red_mole_switch_state)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_ouch_area_area_entered(_area: Area2D) -> void:
	if self_color_red: SignalBus._on_mole_switch_update(false)
	else: SignalBus._on_mole_switch_update(true)
	ouch_area.call_deferred("set_monitoring",false)

func _on_mole_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name == "popup":
		ouch_area.call_deferred("set_monitoring",true)

func _on_global_red_up() -> void:
	if self_color_red: set_up_status(true)
	else: set_up_status(false)

func _on_global_blue_up() -> void:
	if self_color_red: set_up_status(false)
	else: set_up_status(true)


func _on_mole_vis_enabler_screen_entered() -> void:
	instant_update_status()
