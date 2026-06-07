shader_type spatial;
// One Accord — additive billboard for fire/ember particles (gl_compatibility).
// Painted on a QuadMesh driven by GPUParticles3D. Each particle is a soft, hot
// blob whose colour comes from the particle's COLOR (set by the process material
// gradient over its life: white-hot -> orange -> dark ember/smoke). A round soft
// falloff + a little per-quad noise keeps them from looking like flat discs.
render_mode blend_add, cull_disabled, unshaded, depth_draw_never, shadows_disabled, particle_trails;

uniform float softness : hint_range(0.5, 8.0) = 2.4;
uniform float intensity : hint_range(0.0, 8.0) = 2.2;

void vertex() {
	// Billboard toward the camera (keeps quads facing the eye regardless of flight).
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		INV_VIEW_MATRIX[1],
		INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float r = length(uv);
	// Soft round blob, brighter in the middle.
	float a = pow(clamp(1.0 - r, 0.0, 1.0), softness);
	ALBEDO = vec3(0.0);
	EMISSION = COLOR.rgb * intensity * a;
	ALPHA = a * COLOR.a;
}
