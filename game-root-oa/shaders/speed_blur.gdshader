shader_type canvas_item;
// Radial "speed" blur for One Accord — GTA-San-Andreas-style sprint smear.
// A fullscreen ColorRect samples the rendered frame and blurs each pixel along
// the line from screen-center outward, so the edges streak while the center
// stays sharp. `strength` is driven from the player (0 = off, ~1 = full sprint).

uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform float max_offset : hint_range(0.0, 0.2) = 0.045;  // how far the smear reaches
uniform int samples : hint_range(2, 16) = 8;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	if (strength <= 0.001) {
		COLOR = texture(screen_tex, SCREEN_UV);
	} else {
		// Vector from center to this pixel; blur back toward the center.
		vec2 dir = SCREEN_UV - vec2(0.5);
		// Keep the very center crisp, ramp the smear toward the edges.
		float edge = clamp(length(dir) * 2.0, 0.0, 1.0);
		float reach = max_offset * strength * edge;

		vec3 acc = vec3(0.0);
		float total = 0.0;
		for (int i = 0; i < samples; i++) {
			float t = float(i) / float(samples - 1);   // 0..1
			vec2 uv = SCREEN_UV - dir * reach * t;
			float w = 1.0 - t * 0.5;                    // nearer samples weigh more
			acc += texture(screen_tex, uv).rgb * w;
			total += w;
		}
		COLOR = vec4(acc / total, 1.0);
	}
}
