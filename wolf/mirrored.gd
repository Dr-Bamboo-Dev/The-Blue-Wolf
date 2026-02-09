extends WolfMirrorState


#-----------------------------------------
# Inherited Functions
#-----------------------------------------
func enter() -> void:
	wolf_sprite.flip_h = true
	chomp_zone.set_chomp_position(&"left")

func update(_delta:float) -> void:
	if wolf.input_vector.x > 0.0:
		transitioned.emit(self, &"Unmirrored")
		

#-----------------------------------------
# Local Functions
#-----------------------------------------


#-----------------------------------------
# Signal Functions
#-----------------------------------------
