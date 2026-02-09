shader_type canvas_item;

uniform bool red_mode = true;

const vec4 red_1 = vec4(0.757, 0.243, 0.243, 1.0);
const vec4 red_2 = vec4(0.231, 0.09, 0.145, 1.0);
const vec4 red_3 = vec4(0.451, 0.09, 0.176, 1.0);
const vec4 red_4 = vec4(0.91, 0.416, 0.451, 1.0);
const vec4 red_5 = vec4(0.961, 0.627, 0.592, 1.0);

const vec4 blue_1 = vec4(0.157, 0.361, 0.769, 1.0);
const vec4 blue_2 = vec4(0.133, 0.11, 0.102, 1.0);
const vec4 blue_3 = vec4(0.251, 0.2, 0.325, 1.0);
const vec4 blue_4 = vec4(0.141, 0.624, 0.871, 1.0);
const vec4 blue_5 = vec4(0.125, 0.839, 0.78, 1.0);


void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if(!red_mode) {
		if (distance(COLOR, red_1) < 0.1) {
			COLOR = blue_1;
		}
		else if (distance(COLOR, red_2) < 0.1) {
			COLOR = blue_2;
		}
		else if (distance(COLOR, red_3) < 0.1) {
			COLOR = blue_3;
		}
		else if (distance(COLOR, red_4) < 0.1) {
			COLOR = blue_4;
		}
		else if (distance(COLOR, red_5) < 0.1) {
			COLOR = blue_5;
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
