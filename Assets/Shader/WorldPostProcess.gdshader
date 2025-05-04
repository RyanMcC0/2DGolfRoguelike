shader_type canvas_item;

uniform float scale : hint_range(0.1, 10.0) = 2.0;
uniform float strength : hint_range(0.0, 1.0) = 0.2;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

float permute(float x) {
	return mod(((34.0 * x) + 1.0) * x, 289.0);
}

float noise(vec2 v) {
	vec2 i = floor(v);
	vec2 f = fract(v);

	float a = permute(permute(i.x) + i.y);
	float b = permute(permute(i.x + 1.0) + i.y);
	float c = permute(permute(i.x) + i.y + 1.0);
	float d = permute(permute(i.x + 1.0) + i.y + 1.0);

	vec2 u = f * f * (3.0 - 2.0 * f);

	float res = mix(
		mix(a, b, u.x),
		mix(c, d, u.x),
		u.y
	);
	return res / 289.0;
}

void fragment() {
	vec2 uv = SCREEN_UV * scale;
	float n = noise(uv);

	vec4 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = mix(screen_tex, vec4(n, n, n, 1.0), strength);
}