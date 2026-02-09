extends WolfMirrorState


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	wolf_sprite.flip_h = false
	chomp_zone.set_chomp_position(&"right")

func update(_delta:float) -> void:
	if wolf.input_vector.x < 0.0:
		transitioned.emit(self, &"Mirrored")

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
