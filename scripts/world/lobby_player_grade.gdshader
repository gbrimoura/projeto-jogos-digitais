shader_type canvas_item;

varying vec4 lobby_sprite_modulate;
uniform bool arm_mask_active = false;
uniform vec4 arm_mask_rect = vec4(39.0, 37.0, 45.0, 44.0);

void vertex() {
	// CanvasItem COLOR already contains vertex color, modulate, and self_modulate.
	lobby_sprite_modulate = COLOR;
}

vec3 grade_palette_srgb(vec3 source) {
	float luma = dot(source, vec3(0.2126, 0.7152, 0.0722));
	float chroma = max(source.r, max(source.g, source.b)) - min(source.r, min(source.g, source.b));
	vec3 color = source;

	// Warm the bright, low-chroma metal toward ivory without shifting the visor.
	float ivory_amount = smoothstep(0.62, 0.84, luma)
		* (1.0 - smoothstep(0.07, 0.19, chroma)) * 0.72;
	vec3 ivory = vec3(min(luma * 1.04, 1.0), luma * 0.99, luma * 0.90);
	color = mix(color, ivory, ivory_amount);

	// Mute electric blues into a restrained steel-blue ramp at similar luminance.
	float blue_amount = smoothstep(0.12, 0.24, source.b - source.g * 1.05)
		* smoothstep(0.14, 0.30, luma)
		* (1.0 - smoothstep(0.65, 0.80, luma)) * 0.82;
	vec3 steel_blue = vec3(luma * 0.84, luma * 1.08, min(luma * 1.28, 1.0));
	color = mix(color, steel_blue, blue_amount);

	// Shift yellow paint toward the brass already used by the elevator hardware.
	float brass_amount = smoothstep(0.08, 0.22, source.r - source.g)
		* smoothstep(0.18, 0.42, source.g - source.b)
		* smoothstep(0.28, 0.48, luma) * 0.92;
	vec3 brass = vec3(min(luma * 1.07, 1.0), luma * 0.85, luma * 0.47);
	color = mix(color, brass, brass_amount);

	// Add a quiet warm tint to dark contour pixels while retaining their value.
	float ink_amount = (1.0 - smoothstep(0.05, 0.18, luma)) * 0.24;
	vec3 warm_ink = vec3(luma * 1.24 + 0.010, luma * 1.14 + 0.007, luma * 0.96 + 0.004);
	color = mix(color, warm_ink, ink_amount);
	return clamp(color, vec3(0.0), vec3(1.0));
}

void fragment() {
	vec4 texel = texture(TEXTURE, UV);
	vec3 graded_srgb = grade_palette_srgb(texel.rgb);
	COLOR = vec4(
		graded_srgb * lobby_sprite_modulate.rgb,
		texel.a * lobby_sprite_modulate.a
	);
	if (arm_mask_active) {
		vec2 atlas_size = vec2(textureSize(TEXTURE, 0));
		// AtlasTexture supplies atlas UVs; flip_h follows the sampled source pixels.
		// Floor to the sampled texel before applying inclusive native-pixel bounds.
		float native_x = mod(floor(UV.x * atlas_size.x), 64.0);
		float native_y = floor(UV.y * atlas_size.y);
		bool in_cut = native_x >= arm_mask_rect.x && native_x <= arm_mask_rect.z && native_y >= arm_mask_rect.y && native_y <= arm_mask_rect.w;
		if (in_cut) {
			COLOR.a = 0.0;
		}
	}
}
