shader_type canvas_item;

uniform bool active = false;
uniform float flash_intensity = 0.225;
uniform vec4 flash_color : source_color = vec4(1.0, 0.494, 0.427, 1.0);

void fragment() {
	if (active && COLOR.a > 0.1) {
		COLOR = COLOR + (flash_color * flash_intensity);
	}
}
