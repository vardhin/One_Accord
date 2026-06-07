shader_type spatial;
// One Accord — FIREBALL spell (gl_compatibility friendly).
// A roiling, particulate fire orb: domain-warped 3D value noise drives an
// emissive fire gradient, a fresnel core glows white-hot, and the surface boils
// outward. Additive + depth-write-off so many overlapping orbs read as light.
// Shares the spell uniform contract: time / color / color2 / intensity / charge.
render_mode blend_add, cull_disabled, unshaded, depth_draw_never, shadows_disabled;

uniform float time = 0.0;                 // seconds, driven by SpellCaster
uniform vec4 color : source_color = vec4(1.0, 0.45, 0.10, 1.0);   // outer flame
uniform vec4 color2 : source_color = vec4(1.0, 0.92, 0.45, 1.0);  // hot core
uniform float intensity : hint_range(0.0, 12.0) = 3.0;
uniform float charge : hint_range(0.0, 1.0) = 0.0;  // ramps while channelling
uniform float fresnel_power : hint_range(0.5, 8.0) = 2.2;
uniform float boil = 2.6;                 // surface displacement speed
uniform float noise_scale = 3.5;

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
	for (int i = 0; i < 4; i++) {
		s += a * vnoise(p);
		p *= 2.02;
		a *= 0.5;
	}
	return s;
}

varying vec3 v_local;

void vertex() {
	v_local = VERTEX;
	// Boil the surface: push vertices along their normal by animated noise so the
	// silhouette churns. Charge swells the whole orb.
	float t = time * boil;
	float d = fbm(NORMAL * noise_scale + vec3(0.0, t, 0.0));
	float swell = 1.0 + charge * 0.5;
	VERTEX += NORMAL * (d * 0.18 + 0.02) * swell;
}

void fragment() {
	vec3 p = normalize(v_local);
	float t = time * boil;
	// Domain-warped fire field.
	vec3 q = p * noise_scale;
	float warp = fbm(q + vec3(0.0, t, 0.0));
	float fire = fbm(q + warp * 1.5 + vec3(t * 0.5, t, -t * 0.3));
	fire = pow(clamp(fire * 1.6, 0.0, 1.0), 1.4);

	// Fresnel hot core (white-hot toward the centre/edge facing the eye).
	float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), fresnel_power);

	vec3 flame = mix(color.rgb, color2.rgb, fire);
	flame = mix(flame, color2.rgb * 1.6, fres);
	float glow = intensity * (0.6 + 0.8 * fire + charge * 0.6);

	EMISSION = flame * glow;
	ALBEDO = vec3(0.0);
	// Soft, additive: dim, sooty rim fades the orb edge so it isn't a hard ball.
	ALPHA = clamp(fire * 0.9 + fres * 0.7, 0.0, 1.0);
}
