shader_type canvas_item;

// Damage flash var
uniform bool active = false;
uniform float flash_intensity = 0.225;
uniform vec4 flash_color : source_color = vec4(0.997, 0.0, 0.002, 1.0);

uniform bool d_active = false;
uniform float d_flash_intensity = 0.0;
uniform vec4 d_flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Pixel explode var
uniform sampler2D noise_tex_normal;
uniform sampler2D noise_tex;
uniform float progress : hint_range(0.0, 1.0);
uniform float strength = 1.0;

void fragment() {
	// Pixel exlplode
	vec2 direction = texture(noise_tex_normal, UV).xy; // We're using normal map as direction
	direction -= 0.5; // Since our normal map is a texture, it ranges from 0.0 to 1.0...
	direction *= 2.0; // ...so we're going to make it range from -1.0 to 1.0.
	direction = direction * strength * progress;
	
	// UV for exploded texture
	vec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE; // Real texture size in pixels
	vec2 uv = floor(UV * tex_size) / (tex_size - 1.0); // Pixelate UV to snap pixels
	uv = uv - direction; // Distort UV
	
	// Texture with exploded UV
	vec4 tex = texture(TEXTURE, uv); 
	
	// Dissolve alpha
	float dissolve = texture(noise_tex, UV).x;
	dissolve = step(progress, dissolve);
	tex.a *= dissolve;
	
	// Border (in case the edge of your sprite stretches, otherwise you can remove this block)
	vec2 border_uv = uv * 2.0 - 1.0;
	border_uv = clamp(abs(border_uv), 0.0, 1.0);
	float border = max(border_uv.x, border_uv.y);
	border = ceil(1.0 - border);
	tex.a *= border;
	
	COLOR = tex;
	
	// Damage flash
	if (active && COLOR.a > 0.1) {
		COLOR = COLOR + (flash_color * flash_intensity);
	}
	
	// Death flash
	if (d_active && COLOR.a > 0.1) {
		COLOR = COLOR + (d_flash_color * d_flash_intensity);
	}
}
