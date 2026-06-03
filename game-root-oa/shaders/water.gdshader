shader_type spatial;
// Stylized water for One Accord (gl_compatibility friendly).
// Scrolling procedural wave normals + fresnel edge + depth-tinted transparency.
// No SSR / no screen refraction (those need Forward+); reads as water on Vega-8.
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 shallow_color : source_color = vec3(0.26, 0.52, 0.58);
uniform vec3 deep_color : source_color = vec3(0.08, 0.20, 0.30);
uniform float depth_fade : hint_range(0.5, 30.0) = 8.0;
uniform float transparency : hint_range(0.0, 1.0) = 0.82;

uniform vec3 fresnel_color : source_color = vec3(0.7, 0.85, 0.95);
uniform float fresnel_power : hint_range(0.5, 8.0) = 4.0;

uniform float wave_strength : hint_range(0.0, 1.0) = 0.18;
uniform float wave_scale : hint_range(1.0, 60.0) = 18.0;
uniform vec2 wave_dir_a = vec2(1.0, 0.4);
uniform vec2 wave_dir_b = vec2(-0.3, 1.0);
uniform float wave_speed : hint_range(0.0, 1.0) = 0.06;

uniform float roughness_val : hint_range(0.0, 1.0) = 0.06;
uniform float specular_val : hint_range(0.0, 1.0) = 0.6;

uniform sampler2D depth_tex : hint_depth_texture, filter_linear_mipmap;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Build a small perturbation normal from two scrolling noise fields.
vec3 wave_normal(vec2 uv) {
	vec2 a = uv / wave_scale + wave_dir_a * TIME * wave_speed;
	vec2 b = uv / (wave_scale * 0.6) + wave_dir_b * TIME * wave_speed * 1.3;
	float e = 0.05;
	float ha = vnoise(a) + vnoise(b);
	float hx = vnoise(a + vec2(e, 0.0)) + vnoise(b + vec2(e, 0.0));
	float hz = vnoise(a + vec2(0.0, e)) + vnoise(b + vec2(0.0, e));
	vec3 n = normalize(vec3((ha - hx), 1.0, (ha - hz)));
	return normalize(mix(vec3(0.0, 1.0, 0.0), n, wave_strength));
}

void fragment() {
	// World-space XZ for stable, tiling waves regardless of mesh UVs.
	vec3 wpos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 n = wave_normal(wpos.xz);
	NORMAL = (VIEW_MATRIX * vec4(n, 0.0)).xyz;

	// Depth-based color: compare scene depth to this fragment for a shoreline fade.
	float scene_depth = textureLod(depth_tex, SCREEN_UV, 0.0).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, scene_depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float diff = -view.z + VERTEX.z;   // distance from water surface to bottom
	float depth_t = clamp(diff / depth_fade, 0.0, 1.0);

	vec3 col = mix(shallow_color, deep_color, depth_t);

	// Fresnel rim toward grazing angles.
	float fres = pow(1.0 - clamp(dot(normalize(VIEW), NORMAL), 0.0, 1.0), fresnel_power);
	col = mix(col, fresnel_color, fres * 0.6);

	ALBEDO = col;
	ROUGHNESS = roughness_val;
	SPECULAR = specular_val;
	METALLIC = 0.0;

	// Shallower water more transparent at the shoreline.
	ALPHA = mix(transparency * 0.5, transparency, depth_t);
}
