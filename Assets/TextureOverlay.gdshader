shader_type canvas_item;

uniform sampler2D overlay_tex_dirt: repeat_enable, filter_nearest;
uniform sampler2D overlay_tex_water: repeat_enable, filter_nearest;
uniform sampler2D overlay_tex_grass: repeat_enable, filter_nearest;
uniform float scale_dirt = 0.006944444; // calculated by 1/texture size e.g. 1/144
uniform float scale_water = 0.006944444; // calculated by 1/texture size e.g. 1/144
uniform float scale_grass = 0.006944444; // calculated by 1/texture size e.g. 1/144
varying vec2 world_position;
uniform float difference: hint_range(0.0, 1.0) = 0.0;

void vertex(){
	// calculate the world position for use in the fragment shader
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// only apply overlay_tex on the fully red parts of the original tiles
	float mix_amount_dirt = floor(COLOR.r);
	float mix_amount_water = floor(COLOR.b);
	float mix_amount_grass = floor(COLOR.g);

	// sample the overlay_tex using worldPos
	vec4 overlay_color_dirt = texture(overlay_tex_dirt, world_position * scale_dirt);
	vec4 overlay_color_grass = texture(overlay_tex_grass, world_position * scale_grass);
	vec4 overlay_color_water = texture(overlay_tex_water, world_position * scale_water);

	// combine original color and overlay color together
	COLOR = mix(COLOR, overlay_color_dirt, mix_amount_dirt);
	COLOR = mix(COLOR, overlay_color_water, mix_amount_water);
	COLOR = mix(COLOR, overlay_color_grass, mix_amount_grass);


}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
