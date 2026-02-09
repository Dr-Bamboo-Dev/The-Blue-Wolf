@tool
extends Prop

@onready var prop_sprite: Sprite2D = $PropSprite
@onready var wall_body: StaticBody2D = $WallBody
@onready var wall_animator:AnimationPlayer = $WallAnimator
#@export var is_red:bool = true
enum color_enum {RED, BLUE}
@export var wall_raised:bool = true
@export var wall_color:color_enum = color_enum.RED
var colors:Dictionary[color_enum,String] = {
	color_enum.RED: "red",
	color_enum.BLUE: "blue"
}

#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func _prop_ready() -> void:
	if not Engine.is_editor_hint():
		if wall_color == color_enum.RED:
			SignalBus.mole_switches_red.connect(wall_raise)
			SignalBus.mole_switches_blue.connect(wall_lower)
		else:
			SignalBus.mole_switches_red.connect(wall_lower)
			SignalBus.mole_switches_blue.connect(wall_raise)
		set_wall_sprite_color()
		if not wall_raised:
			print(name, " is down")
			wall_raised = false
			set_solid_status(false)
			prop_sprite.frame_coords.x = 33
			#z_index = -1

func _prop_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		set_wall_sprite_color()
		if wall_raised:
			prop_sprite.frame_coords.x = 0
		else:
			prop_sprite.frame_coords.x = 33

#-----------------------------------------
# Local Functions
#-----------------------------------------
func wall_raise() -> void:
	if wall_raised: return
	wall_raised = true
	var anim_color:String = colors[wall_color]
	z_index = 0
	wall_animator.play("raise_" + anim_color)
	set_solid_status(true)

func wall_lower() -> void:
	if not wall_raised: return
	wall_raised = false
	var anim_color:String = colors[wall_color]
	wall_animator.play("lower_" + anim_color)

func wall_toggle() -> void:
	if wall_raised:
		wall_lower()
	else:
		wall_raise()

func set_wall_sprite_color() -> void:
	match wall_color:
		color_enum.RED:
			prop_sprite.frame_coords.y = 0
		color_enum.BLUE:
			prop_sprite.frame_coords.y = 1

func set_solid_status(new_state:bool) -> void:
	#print("setting wall solid status to: ", new_state)
	if new_state:
		wall_body.call_deferred("set_process_mode",Node.PROCESS_MODE_INHERIT)
	else:
		wall_body.call_deferred("set_process_mode",Node.PROCESS_MODE_DISABLED)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_wall_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name.get_slice("_",0) == "lower":
		set_solid_status(false)
		z_index = -1
