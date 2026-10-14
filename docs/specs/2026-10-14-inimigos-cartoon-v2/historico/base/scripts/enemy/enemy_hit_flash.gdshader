shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 0.945098, 0.780392, 1.0);

varying vec4 vertex_modulate;

void vertex() {
	vertex_modulate = COLOR;
}

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	vec3 rgb = mix(source.rgb, flash_color.rgb, clamp(flash_amount, 0.0, 1.0));
	COLOR = vec4(rgb, source.a) * vertex_modulate;
}
