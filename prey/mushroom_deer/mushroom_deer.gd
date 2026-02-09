extends CharacterBody2D

var chomp_particles:PackedScene = preload("res://prey/mushroom_deer/chomp_particles.tscn")
var scare_zone_watchers:Array[Node] = []
var away_vector:Vector2 = Vector2.ZERO
var is_chomped:bool = false
@onready var deer_sprite: Sprite2D = $DeerSprite
@onready var deer_state_machine: Node = $DeerStateMachine
@onready var scare_zone: Area2D = $ScareZone
@onready var space_bubble: Area2D = $SpaceBubble

#-----------------------------------------
# Built in Functions
#-----------------------------------------
func _ready() -> void:
	pass
	

func _physics_process(_delta: float) -> void:
	if space_bubble.has_overlapping_areas():
		var new_away_vector:Vector2 = Vector2.ZERO
		
		
		for bubble in space_bubble.get_overlapping_areas():
			if bubble.owner.get_node("DeerStateMachine").current_state.name == "DeerFlee":
				deer_state_machine.start_scare()
			
			new_away_vector += bubble.global_position.direction_to(space_bubble.global_position)
		new_away_vector = new_away_vector.normalized()
		new_away_vector *= 100
		
		away_vector = away_vector.move_toward(new_away_vector, 0.04)
	else:
		away_vector = away_vector.move_toward(Vector2.ZERO, 0.05)
		if not scare_zone.has_overlapping_bodies():
			if deer_state_machine.current_state.name == "DeerFlee":
				deer_state_machine.stop_scare()
			
		#space_bubble.get_overlapping_areas()[0].global_position
	
	if velocity.x > 0: deer_sprite.flip_h = false
	elif velocity.x < 0: deer_sprite.flip_h = true
	move_and_slide()

#-----------------------------------------
# Local Functions
#-----------------------------------------
func chomp_splat() -> void:
	var new_splat:Node2D = chomp_particles.instantiate()
	new_splat.global_position = global_position
	get_parent().add_child(new_splat)
	#get_tree().current_scene.add_child(new_splat)
	#print(get_tree().current_scene)

#-----------------------------------------
# Signal Functions
#-----------------------------------------
func _on_scare_zone_body_entered(_body: Node2D) -> void:
	deer_state_machine.start_scare()

func _on_scare_zone_body_exited(_body: Node2D) -> void:
	deer_state_machine.stop_scare()

func _on_ouch_zone_area_entered(_area: Area2D) -> void:
	deer_state_machine.chomped()

func _on_deer_chomped_chomped() -> void:
	chomp_splat()
