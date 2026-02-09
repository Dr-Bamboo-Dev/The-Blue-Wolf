shader_type canvas_item;

uniform vec4 _Color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float _Radius : hint_range(0.0, 1.5, 0.001) = 0.8;
uniform float _Smoot : hint_range(0.0, 2.0, 0.01) = 0.78;
uniform vec2 _Position = vec2(0.5, 0.5);
uniform float opacity : hint_range(0.0, 1.0, 0.001) = 0.0;

float one_minus_f(in float input)
{
	return 1.0 - input;
}

float circle(in float radius, in float smoot, in vec2 position, in vec2 st)
{
	smoot = max(smoot, 0.0001); // Prev div 0.

	vec2 p = position - st;
	float offset = distance(vec2(0.844, 0.5), position);
	float r = length(p) / (1.0 + offset);

	return smoothstep(radius, radius - smoot, r);
}

void fragment() {
	vec2 resolution = 1.0 / vec2(1280.0/3.0, 720.0); // Get resolution.

	vec2 st = UV; // Base UV.

	float fix_pos = resolution.x / resolution.y;

	st.x *= fix_pos; // Fix UV ratio.

	vec2 pos = _Position;
	pos.x *= fix_pos; // Fix position.

	if (COLOR.a > 0.0) {
		COLOR = _Color;
	}
	COLOR *= vec4(one_minus_f( circle(_Radius, _Smoot, pos, st) )) * _Color;
	COLOR.a = COLOR.a * opacity;
}