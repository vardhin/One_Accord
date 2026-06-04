// One Accord — interactive grass (adapted from Terrain3D's particle grass shader,
// addons/terrain_3d/extras/particle_example/grass.gdshader).
//
// Adds PLAYER/ACTOR BEND on top of the original wind: blades near a "bender"
// (the player, later NPCs) push away from it and spring back when it leaves.
// Bend is a global uniform array fed every frame by grass_benders.gd. Copied into
// the project so the addon stays pristine and updatable.
//
// Original wind/colour logic by Cory Petkovsek, Roope Palmroos, and Contributors.
shader_type spatial;

render_mode skip_vertex_transform, cull_disabled, blend_mix;

uniform vec2 wind_direction = vec2(1.0, 1.0);

// --- Interaction -----------------------------------------------------------
// Each bender = vec4(world_x, world_y, world_z, radius). w <= 0 means "unused".
// Fed per-frame by grass_benders.gd. (Godot doesn't allow `global uniform`
// arrays, so this is a regular uniform on the shared grass material — setting it
// once per frame updates every grid node that shares the material.)
uniform vec4 grass_benders[8];
uniform int grass_bender_count = 0;
// How hard blades push away from a bender (metres at the tip, at point-blank).
uniform float bend_strength = 0.55;

varying vec4 data;

void vertex() {
	// --- Original Terrain3D wind logic (unchanged) -------------------------
	data[2] = (VERTEX.y + 0.55);
	data[2] *= data[2]; // make non-linear

	// Ribbon used as a grass mesh.. so pinch the top.
	VERTEX.xz *= (1.0 - data[2]);

	// Brighten tips
	COLOR = mix(COLOR, vec4(1.0), smoothstep(0.9, 1.0, data[2]));
	// Darken base, skip if scale is less than threshold (the "grow in").
	COLOR *= INSTANCE_CUSTOM[3] < 0.35 ? 1. : mix(1.0, 0.75, smoothstep(0.35, 0.0, data[2]));
	data.rg = INSTANCE_CUSTOM.rg;

	vec3 w_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float scale = pow(INSTANCE_CUSTOM[3] * INSTANCE_CUSTOM[3], 0.707);
	float force = INSTANCE_CUSTOM[2] * data[2] * scale;
	force -= fract(force * 256.0) * force * 0.05;
	force = pow(force, 0.707);

	float lateral_wobble = sin(TIME * 2.0 * (1.0 + data.r + data.g)) * 0.25 * (1.0 - INSTANCE_CUSTOM[2]);
	vec2 direction = normalize(wind_direction);
	w_vertex.xz -= (vec2(-direction.y, direction.x) * lateral_wobble + direction) * force;
	w_vertex.y -= INSTANCE_CUSTOM[2] * force * data[2];

	data[3] = force;

	// --- Player / actor bend ------------------------------------------------
	// Push the blade away from each nearby bender, more toward the tip (data[2]
	// is the squared, normalized height: ~0 at the base, ~1 at the tip). The
	// blade's BASE stays planted; only the upper part leans.
	vec3 base_ws = MODEL_MATRIX[3].xyz;          // where this blade is rooted
	for (int i = 0; i < grass_bender_count; i++) {
		vec4 b = grass_benders[i];
		float radius = b.w;
		if (radius <= 0.0) { continue; }
		vec2 to_blade = base_ws.xz - b.xz;
		float dist = length(to_blade);
		if (dist >= radius) { continue; }
		// 1 at the bender, 0 at the radius edge (smooth falloff).
		float fall = 1.0 - smoothstep(0.0, radius, dist);
		fall = fall * fall;                       // sharper near the actor
		vec2 push_dir = dist > 0.0001 ? to_blade / dist : direction;
		float lean = bend_strength * fall * data[2];
		w_vertex.xz += push_dir * lean;
		// Pressed down a little where the lean is strong (trodden look).
		w_vertex.y -= lean * 0.4;
	}

	VERTEX = (VIEW_MATRIX * vec4(w_vertex, 1.0)).xyz;
	NORMAL = MODELVIEW_NORMAL_MATRIX * NORMAL;
	BINORMAL = MODELVIEW_NORMAL_MATRIX * BINORMAL;
	TANGENT = MODELVIEW_NORMAL_MATRIX * TANGENT;
}

void fragment() {
	ALBEDO = vec3(0.20, 0.22, 0.05) * (data[2] * 0.5 + 0.5);
	ALBEDO.rg *= (data.rg * 0.3 + 0.9);
	ALBEDO *= pow(COLOR.rgb, vec3(2.2));
	float spec_rough = clamp(max(data[2], data[3]), 0., 1.);
	ROUGHNESS = 1. - spec_rough;
	SPECULAR = clamp(spec_rough * 0.25, 0., .15);

	BACKLIGHT = vec3(0.33);
	#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	ALBEDO = pow(ALBEDO, vec3(0.4));
	#endif
}
