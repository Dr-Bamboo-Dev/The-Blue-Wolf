shader_type canvas_item;

instance uniform bool flashing = false;

//void vertex() {
	// Called for every vertex the material is visible on.
//}

void fragment() {
	if (flashing) {
		if (COLOR.a > 0.0) {
			COLOR = vec4(1.0, 1.0, 1.0, COLOR.a);
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
