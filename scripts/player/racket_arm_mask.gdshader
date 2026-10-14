shader_type canvas_item;

uniform bool arm_mask_active = false;
uniform vec4 arm_mask_rect = vec4(39.0, 37.0, 45.0, 44.0);

void fragment() {
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
