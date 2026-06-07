shader_type spatial;
// One Accord — MAGIC BOLT spell (gl_compatibility friendly).
// An arcane energy orb: concentric energy shells + orbiting spark filaments that
// swirl around a bright fresnel core, pulsing with charge. Additive emissive.
// Shares the spell uniform contract: time / color / color2 / intensity / charge.
render_mode blend_add, cull_disabled, unshaded, depth_draw_never, shadows_disabled;

uniform float time = 0.0;
uniform vec4 color : source_color = vec4(0.35, 0.55, 1.0, 1.0);   // outer arcane
uniform vec4 color2 : source_color = vec4(0.85, 0.95, 1.0, 1.0);  // bright core
uniform float intensity : hint_range(0.0, 12.0) = 3.5;
uniform float charge : hint_range(0.0, 1.0) = 0.0;
uniform float fresnel_power : hint_range(0.5, 8.0) = 3.0;
uniform float swirl_speed = 2.2;
uniform float filaments = 7.0;            // number of orbiting spark bands

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
	float a = hash3(i).x;
	float b = hash3(i + vec3(1,0,0)).x;
	float c = hash3(i + vec3(0,1,0)).x;
	float d = hash3(i + vec3(1,1,0)).x;
	float e = hash3(i + vec3(0,0,1)).x;
	float f1 = hash3(i + vec3(1,0,1)).x;
	float g = hash3(i + vec3(0,1,1)).x;
	float h = hash3(i + vec3(1,1,1)).x;
	return mix(mix(mix(a,b,u.x), mix(c,d,u.x), u.y),
			   mix(mix(e,f1,u.x), mix(g,h,u.x), u.y), u.z);
}

varying vec3 v_local;

void vertex() {
	v_local = VERTEX;
	float swell = 1.0 + charge * 0.35 + 0.04 * sin(time * 6.0);
	VERTEX *= swell;
}

void fragment() {
	vec3 p = normalize(v_local);
	float t = time * swirl_speed;

	// Spherical coords -> swirling filament bands. Latitude bands rotate in
	// longitude over time, sharpened into thin arcs.
	float lon = atan(p.z, p.x);
	float lat = asin(clamp(p.y, -1.0, 1.0));
	float bands = sin(lat * filaments + sin(lon * 3.0 + t) * 2.0 + t * 1.7);
	float spark = pow(clamp(bands, 0.0, 1.0), 6.0);

	// Energy shimmer over the surface.
	float shimmer = vnoise(p * 5.0 + vec3(0.0, t, 0.0));

	float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), fresnel_power);

	vec3 col = mix(color.rgb, color2.rgb, fres);
	col = mix(col, color2.rgb * 1.8, spark);
	float pulse = 0.7 + 0.3 * sin(time * 8.0) + charge * 0.6;
	float glow = intensity * (0.5 + 0.6 * shimmer + spark * 1.2) * pulse;

	EMISSION = col * glow;
	ALBEDO = vec3(0.0);
	ALPHA = clamp(fres * 0.7 + spark + shimmer * 0.3, 0.0, 1.0);
}
