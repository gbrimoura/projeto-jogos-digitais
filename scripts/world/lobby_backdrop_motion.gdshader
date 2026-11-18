shader_type canvas_item;

const float SOURCE_WIDTH = 1672.0;
const float SOURCE_HEIGHT = 941.0;
const float LOOP_SECONDS = 36.0;
const float TAU_VALUE = 6.28318530718;

uniform float drift_amplitude_px = 28.0;

varying vec4 item_modulate;

void vertex() {
	item_modulate = COLOR;
}

float soft_pulse(float cycle_phase, float pulses_per_loop, float pulse_start, float pulse_length) {
	float phase = fract(cycle_phase * pulses_per_loop - pulse_start);
	float attack = smoothstep(0.0, 0.05, phase);
	float release = 1.0 - smoothstep(pulse_length * 0.55, pulse_length, phase);
	return attack * release;
}

float local_light(vec2 source_px, vec2 center_px, float radius_px, float pulse) {
	float radius_mask = 1.0 - smoothstep(radius_px * 0.45, radius_px, distance(source_px, center_px));
	return radius_mask * pulse;
}

void fragment() {
	float cycle_phase = fract(TIME / LOOP_SECONDS);
	float source_x = UV.x * SOURCE_WIDTH;
	float source_y = UV.y * SOURCE_HEIGHT;

	// Sky-only cloud motion: safe source region x=58..1020, y<275, with feathered edges.
	float horizontal_mask = smoothstep(58.0 / SOURCE_WIDTH, 142.0 / SOURCE_WIDTH, UV.x)
		* (1.0 - smoothstep(920.0 / SOURCE_WIDTH, 1020.0 / SOURCE_WIDTH, UV.x));
	float sky_mask = 1.0 - smoothstep(230.0 / SOURCE_HEIGHT, 275.0 / SOURCE_HEIGHT, UV.y);
	float cloud_mask = horizontal_mask * sky_mask;
	float cloud_offset_px = drift_amplitude_px * sin(cycle_phase * TAU_VALUE);
	vec2 sample_uv = clamp(UV + vec2((cloud_offset_px * cloud_mask) / SOURCE_WIDTH, 0.0), vec2(0.0), vec2(1.0));
	vec4 texel = texture(TEXTURE, sample_uv);

	// Restrict brightness pulses to warm pixels around existing workshop/elevator lights.
	float warm_pixels = smoothstep(0.45, 0.78, max(texel.r, texel.g))
		* smoothstep(0.03, 0.18, texel.r - texel.b)
		* smoothstep(0.02, 0.14, texel.g - texel.b);
	float light_pulses = 0.0;
	light_pulses += local_light(vec2(source_x, source_y), vec2(199.0, 674.0), 17.0, soft_pulse(cycle_phase, 6.0, 0.07, 0.22));
	light_pulses += local_light(vec2(source_x, source_y), vec2(693.0, 596.0), 18.0, soft_pulse(cycle_phase, 4.0, 0.31, 0.20));
	light_pulses += local_light(vec2(source_x, source_y), vec2(1242.0, 635.0), 18.0, soft_pulse(cycle_phase, 3.0, 0.55, 0.18));
	light_pulses += local_light(vec2(source_x, source_y), vec2(1544.0, 635.0), 18.0, soft_pulse(cycle_phase, 4.0, 0.78, 0.20));
	light_pulses += local_light(vec2(source_x, source_y), vec2(1314.0, 61.0), 10.0, soft_pulse(cycle_phase, 9.0, 0.19, 0.15));
	light_pulses += local_light(vec2(source_x, source_y), vec2(1463.0, 61.0), 10.0, soft_pulse(cycle_phase, 9.0, 0.67, 0.15));
	texel.rgb *= 1.0 - warm_pixels * min(light_pulses, 1.0) * 0.22;
	COLOR = texel * item_modulate;
}
