shader_type spatial;
// One Accord — PLASMA draw pass (gl_compatibility friendly).
// Billboarded additive blob for each advected plasma parcel. Colour is a
// blackbody-style ramp driven by the parcel's COOLING value (CUSTOM.z, written
// by plasma_process.gdshader): white-hot at birth → yellow → orange → deep red
// → smoke as it ages. Per-particle phase (CUSTOM.x) adds flicker so the sheet of
// parcels shimmers like real flame rather than fading uniformly.
render_mode blend_add, cull_disabled, unshaded, depth_draw_never, shadows_disabled;

uniform vec4 col_hot   : source_color = vec4(1.0, 0.98, 0.85, 1.0); // core
uniform vec4 col_mid   : source_color = vec4(1.0, 0.55, 0.12, 1.0); // flame
uniform vec4 col_cool  : source_color = vec4(0.7, 0.08, 0.02, 1.0); // ember
uniform vec4 col_smoke : source_color = vec4(0.05, 0.04, 0.04, 1.0);// dying
uniform float intensity : hint_range(0.0, 12.0) = 3.0;
uniform float softness  : hint_range(0.5, 8.0) = 2.6;
uniform float flicker   : hint_range(0.0, 2.0) = 0.6;

varying float v_cool;
varying float v_phase;

void vertex() {
	// Per-particle data the PROCESS shader wrote into CUSTOM arrives here as
	// INSTANCE_CUSTOM (CUSTOM in a spatial shader is the mesh's own custom = 0).
	v_cool = INSTANCE_CUSTOM.z;
	v_phase = INSTANCE_CUSTOM.x;
	// Camera-facing billboard.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		INV_VIEW_MATRIX[1],
		INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

vec3 ramp(float c) {
	c = clamp(c, 0.0, 1.0);
	vec3 x = mix(col_hot.rgb,  col_mid.rgb,   smoothstep(0.0, 0.35, c));
	x = mix(x, col_cool.rgb,  smoothstep(0.35, 0.7, c));
	x = mix(x, col_smoke.rgb, smoothstep(0.75, 1.0, c));
	return x;
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float r = length(uv);
	float blob = pow(clamp(1.0 - r, 0.0, 1.0), softness);

	// Flicker: cheap per-particle brightness wobble.
	float fl = 1.0 + flicker * (sin(TIME * 18.0 + v_phase * 6.283) * 0.5);

	vec3 c = ramp(v_cool);
	// Hot parcels emit hard; smoke parcels barely glow but still occlude as dark.
	float heat = 1.0 - smoothstep(0.6, 1.0, v_cool);
	EMISSION = c * intensity * blob * fl * heat;
	ALBEDO = vec3(0.0);
	ALPHA = blob * mix(0.25, 1.0, heat);
}
