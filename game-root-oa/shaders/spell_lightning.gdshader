shader_type spatial;
// One Accord — LIGHTNING BEAM spell (gl_compatibility friendly).
// A channelled arc from the sword tip: a stretched box whose surface shows a
// jittering electric filament down its length (local -Z), with a hot core and
// crackling branches. Built for BEAM emit mode (held to channel).
//
// The mesh is a unit box scaled by SpellCaster: long axis = local Z (beam runs
// from z=+0.5 at the muzzle to z=-0.5 at the far end), cross-section = X/Y.
// Shares the spell uniform contract: time / color / color2 / intensity / charge.
render_mode blend_add, cull_disabled, unshaded, depth_draw_never, shadows_disabled;

uniform float time = 0.0;
uniform vec4 color : source_color = vec4(0.55, 0.7, 1.0, 1.0);    // arc tint
uniform vec4 color2 : source_color = vec4(0.95, 0.98, 1.0, 1.0);  // white core
uniform float intensity : hint_range(0.0, 16.0) = 5.0;
uniform float charge : hint_range(0.0, 1.0) = 0.0;
uniform float arc_jitter = 0.22;          // how wild the bolt path is
uniform float arc_freq = 9.0;             // zig-zags per unit length
uniform float flicker_speed = 30.0;
uniform float core_thickness : hint_range(0.005, 0.5) = 0.08;

float hash(float n) { return fract(sin(n) * 43758.5453123); }

// 1D-ish noise along the beam length for the bolt's wander.
float n1(float x) {
	float i = floor(x);
	float f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(hash(i), hash(i + 1.0), f);
}

varying vec3 v_local;

void vertex() {
	v_local = VERTEX;
}

void fragment() {
	// Beam-space coords: u along length (-Z), and the 2D cross-section offset.
	float u = v_local.z + 0.5;             // 0 at far end .. 1 at muzzle
	vec2 cross = v_local.xy;               // distance from the beam's central axis

	float t = time;
	// Two octaves of wander give the bolt its branching path; it crackles fast.
	float jx = (n1(u * arc_freq + t * 6.0) - 0.5) + 0.5 * (n1(u * arc_freq * 2.3 - t * 9.0) - 0.5);
	float jy = (n1(u * arc_freq + 17.0 + t * 5.0) - 0.5) + 0.5 * (n1(u * arc_freq * 2.1 + t * 7.0) - 0.5);
	vec2 center = vec2(jx, jy) * arc_jitter * (0.5 + charge * 0.8);

	float dist = length(cross - center);
	// Sharp glowing core that fattens with charge.
	float core = core_thickness * (0.6 + charge * 0.9);
	float bolt = core / (dist + 0.0008);
	bolt = clamp(bolt, 0.0, 1.5);

	// Fast flicker + taper so the beam fades toward the far end and strobes.
	float flick = 0.7 + 0.3 * n1(t * flicker_speed);
	float taper = smoothstep(0.0, 0.15, u);   // soft start at the far tip

	vec3 col = mix(color.rgb, color2.rgb, clamp(bolt, 0.0, 1.0));
	float glow = intensity * bolt * flick * taper * (0.8 + charge * 0.8);

	EMISSION = col * glow;
	ALBEDO = vec3(0.0);
	ALPHA = clamp(bolt * taper, 0.0, 1.0);
}
