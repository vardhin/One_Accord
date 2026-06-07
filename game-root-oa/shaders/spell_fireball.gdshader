shader_type spatial;
// One Accord — FIREBALL core (gl_compatibility friendly).
// This is the DENSE, white-hot heart of the fireball. It is deliberately NOT a
// translucent shell — the soap-bubble look came from an unshaded sphere whose
// alpha was driven by fresnel, so you saw straight through it. Here the core is
// opaque-ish and hot in the middle, ragged/transparent only at the very rim,
// where the GPUParticles flames take over (see spell_caster.gd). Domain-warped
// fbm boils the surface and drives a blackbody-style fire gradient.
// Shares the spell uniform contract: time / color / color2 / intensity / charge.
render_mode blend_add, cull_disabled, unshaded, depth_draw_never, shadows_disabled;

uniform float time = 0.0;                 // seconds, driven by SpellCaster
uniform vec4 color : source_color = vec4(1.0, 0.45, 0.10, 1.0);   // outer flame
uniform vec4 color2 : source_color = vec4(1.0, 0.92, 0.45, 1.0);  // hot core
uniform float intensity : hint_range(0.0, 12.0) = 3.0;
uniform float charge : hint_range(0.0, 1.0) = 0.0;  // ramps while channelling
uniform float boil = 3.4;                 // surface displacement speed
uniform float noise_scale = 3.2;

// --- cheap 3D value noise + fbm (no textures; Vega-8 safe) -----------------
vec3 hash3(vec3 p) {
	p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
			 dot(p, vec3(269.5, 183.3, 246.1)),
			 dot(p, vec3(113.5, 271.9, 124.6)));
	return fract(sin(p) * 43758.5453123);
}

float vnoise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	vec3 u = f * f * (3.0 - 2.0 * f);
	float n000 = hash3(i + vec3(0,0,0)).x;
	float n100 = hash3(i + vec3(1,0,0)).x;
	float n010 = hash3(i + vec3(0,1,0)).x;
	float n110 = hash3(i + vec3(1,1,0)).x;
	float n001 = hash3(i + vec3(0,0,1)).x;
	float n101 = hash3(i + vec3(1,0,1)).x;
	float n011 = hash3(i + vec3(0,1,1)).x;
	float n111 = hash3(i + vec3(1,1,1)).x;
	float nx00 = mix(n000, n100, u.x);
	float nx10 = mix(n010, n110, u.x);
	float nx01 = mix(n001, n101, u.x);
	float nx11 = mix(n011, n111, u.x);
	float nxy0 = mix(nx00, nx10, u.y);
	float nxy1 = mix(nx01, nx11, u.y);
	return mix(nxy0, nxy1, u.z);
}

float fbm(vec3 p) {
	float a = 0.5;
	float s = 0.0;
	for (int i = 0; i < 5; i++) {
		s += a * vnoise(p);
		p *= 2.03;
		a *= 0.5;
	}
	return s;
}

// Blackbody-ish ramp: dark red -> orange -> yellow -> white as t rises.
vec3 fire_ramp(float t, vec3 cool, vec3 hot) {
	t = clamp(t, 0.0, 1.0);
	vec3 c = mix(cool * 0.25, cool, smoothstep(0.0, 0.35, t)); // ember -> flame
	c = mix(c, hot, smoothstep(0.35, 0.75, t));                // flame -> core
	c = mix(c, vec3(1.0, 0.97, 0.85), smoothstep(0.8, 1.0, t));// core -> white hot
	return c;
}

varying vec3 v_local;

void vertex() {
	v_local = VERTEX;
	// Boil the silhouette so it never reads as a clean sphere. Faster + deeper
	// than before, and charge swells the orb while channelling.
	float t = time * boil;
	float d = fbm(NORMAL * noise_scale + vec3(0.0, t * 0.6, 0.0));
	float d2 = fbm(NORMAL * (noise_scale * 2.1) - vec3(t * 0.4, 0.0, t * 0.2));
	float disp = d * 0.22 + d2 * 0.10 + 0.02;
	float swell = 1.0 + charge * 0.5;
	VERTEX += NORMAL * disp * swell;
}

void fragment() {
	vec3 p = normalize(v_local);
	float t = time * boil;

	// Two-octave domain warp -> turbulent, licking flame field.
	vec3 q = p * noise_scale;
	vec3 warp = vec3(
		fbm(q + vec3(0.0, t, 0.0)),
		fbm(q + vec3(5.2, t * 0.8, 1.3)),
		fbm(q + vec3(-2.1, t * 1.2, 4.7))
	);
	float fire = fbm(q + warp * 2.0 + vec3(t * 0.4, t, -t * 0.3));
	// abs()-folded turbulence sharpens flame tongues vs the old soft blob.
	float turb = abs(fbm(q * 1.8 + warp - vec3(0.0, t * 1.6, 0.0)) - 0.5) * 2.0;
	fire = clamp(fire * 1.3 + (1.0 - turb) * 0.4, 0.0, 1.0);
	fire = pow(fire, 1.25);

	// Radial heat: hot, opaque centre that cools toward the rim. This is what
	// kills the bubble look — the middle is a solid glowing mass, not see-through.
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float core = smoothstep(0.15, 0.95, facing); // 1 at centre, 0 at rim

	float heat = clamp(fire * 0.55 + core * 0.65 + charge * 0.2, 0.0, 1.0);
	vec3 flame = fire_ramp(heat, color.rgb, color2.rgb);

	float glow = intensity * (0.7 + 1.1 * heat + charge * 0.6);
	EMISSION = flame * glow;
	ALBEDO = vec3(0.0);

	// Opaque, ragged core; only the noisy rim fades out so flame particles blend
	// in. No fresnel-driven transparency = no soap bubble.
	float rim = smoothstep(0.0, 0.45, core);
	ALPHA = clamp(rim + fire * 0.6, 0.05, 1.0);
}
