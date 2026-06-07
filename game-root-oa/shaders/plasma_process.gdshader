shader_type particles;
// One Accord — PLASMA FLUID core (gl_compatibility friendly).
// =============================================================================
// This is the reusable "fluid module". It is a CUSTOM GPUParticles3D PROCESS
// shader: each particle is a parcel of plasma/gas, and instead of scripted
// straight-line motion we ADVECT it through a synthetic velocity field every
// frame — the same idea a real fluid solver uses (advect parcels along a
// velocity field), just with the field generated procedurally from CURL NOISE
// instead of solved from Navier–Stokes (compute shaders don't exist on the
// gl_compatibility renderer, so a true grid/SPH solver isn't available here).
//
// WHY CURL NOISE: the curl of a noise field is divergence-free, i.e. it has no
// sources/sinks — fluid neither appears nor vanishes, it just swirls. That is
// exactly what makes smoke/fire/plasma look like a FLUID rather than particles
// drifting. Crank `turbulence` down and you get smooth LAMINAR flow (a clean
// jet); crank it up and the flow shreds into the chaotic, explosive churn of
// real fire. Same field, two regimes — driven entirely by the inspector sliders
// the PlasmaEmitter node exposes (see scripts/plasma_emitter.gd).
//
// LATER: a wind spell is THIS shader with buoyancy≈0, high drag, cool colour and
// a directional bias — the module is spell-agnostic.
// =============================================================================

// ---- Source / emission --------------------------------------------------
uniform float emit_radius = 0.12;        // sphere radius particles spawn within
uniform vec3  jet_dir = vec3(0.0, 0.0, -1.0); // forward (sword -Z), in emitter space
uniform float jet_speed = 6.0;           // initial speed along jet_dir (the "release")
uniform float jet_spread = 0.25;         // 0 = tight cone, 1 = wide cone
uniform float burst_speed = 0.0;         // extra FORWARD speed on a tap (the gout)

// ---- Fluid field ---------------------------------------------------------
uniform float turbulence = 1.0;          // strength of curl-noise swirl (laminar..chaotic)
uniform float turb_scale = 2.2;          // spatial frequency of the eddies
uniform float turb_speed = 1.5;          // how fast the eddy field evolves
uniform float push = 6.0;                // accel ALONG the jet (flamethrower thrust)
uniform float buoyancy = 0.5;            // upward accel (use for vertical bonfire spells)
uniform float drag = 1.2;                // velocity damping (viscosity-ish)
uniform float swirl = 0.0;               // rotation around jet axis (vortex)

// ---- Field-aligned curl noise (no textures; Vega-8 safe) ------------------
vec3 hash33(vec3 p) {
	p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
			 dot(p, vec3(269.5, 183.3, 246.1)),
			 dot(p, vec3(113.5, 271.9, 124.6)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float snoise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	vec3 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(dot(hash33(i + vec3(0,0,0)), f - vec3(0,0,0)),
					   dot(hash33(i + vec3(1,0,0)), f - vec3(1,0,0)), u.x),
				   mix(dot(hash33(i + vec3(0,1,0)), f - vec3(0,1,0)),
					   dot(hash33(i + vec3(1,1,0)), f - vec3(1,1,0)), u.x), u.y),
			   mix(mix(dot(hash33(i + vec3(0,0,1)), f - vec3(0,0,1)),
					   dot(hash33(i + vec3(1,0,1)), f - vec3(1,0,1)), u.x),
				   mix(dot(hash33(i + vec3(0,1,1)), f - vec3(0,1,1)),
					   dot(hash33(i + vec3(1,1,1)), f - vec3(1,1,1)), u.x), u.y), u.z);
}

// Potential field whose CURL we take → divergence-free flow.
vec3 potential(vec3 p) {
	return vec3(snoise(p + vec3(0.0, 0.0, 0.0)),
				snoise(p + vec3(31.7, 11.3, 5.1)),
				snoise(p + vec3(7.2, 53.1, 19.4)));
}

// Numerical curl of the potential (central differences).
vec3 curl_noise(vec3 p) {
	const float e = 0.1;
	vec3 dx = vec3(e, 0.0, 0.0);
	vec3 dy = vec3(0.0, e, 0.0);
	vec3 dz = vec3(0.0, 0.0, e);
	float x = (potential(p + dy).z - potential(p - dy).z) - (potential(p + dz).y - potential(p - dz).y);
	float y = (potential(p + dz).x - potential(p - dz).x) - (potential(p + dx).z - potential(p - dx).z);
	float z = (potential(p + dx).y - potential(p - dx).y) - (potential(p + dy).x - potential(p - dy).x);
	return vec3(x, y, z) / (2.0 * e);
}

// Deterministic per-particle random in [0,1) from the engine RANDOM_SEED + index.
float rnd(inout uint seed) {
	seed = seed * 747796405u + 2891336453u;
	uint r = ((seed >> ((seed >> 28u) + 4u)) ^ seed) * 277803737u;
	r = (r >> 22u) ^ r;
	return float(r) / 4294967295.0;
}

void start() {
	uint seed = uint(RANDOM_SEED) + INDEX * 1099087573u;

	// --- spawn position: inside a small sphere at the muzzle ---
	float u1 = rnd(seed); float u2 = rnd(seed); float u3 = rnd(seed);
	vec3 onsphere = normalize(vec3(u1, u2, u3) * 2.0 - 1.0 + vec3(1e-4));
	vec3 pos = onsphere * emit_radius * pow(rnd(seed), 0.3333);
	TRANSFORM[3].xyz = (EMISSION_TRANSFORM * vec4(pos, 1.0)).xyz;

	// --- initial velocity: a jet along jet_dir, widened by jet_spread, plus an
	//     optional omnidirectional burst (tap = the explosive release). ---
	vec3 dir = normalize(jet_dir);
	vec3 rndv = vec3(rnd(seed), rnd(seed), rnd(seed)) * 2.0 - 1.0;
	vec3 spread = rndv - dir * dot(rndv, dir);     // component perpendicular to jet
	// Forward jet widened into a CONE by jet_spread; burst adds forward gout speed
	// (not radial — radial is what made it a sparkler fan).
	vec3 vel = dir * (jet_speed + burst_speed) + spread * (jet_spread * jet_speed);
	// Rotate into world space (so the jet follows the sword's aim).
	vel = (EMISSION_TRANSFORM * vec4(vel, 0.0)).xyz;
	VELOCITY = vel;

	// CUSTOM layout (Godot 4 particle process shaders have no AGE builtin, so we
	// track life ourselves): .x = flicker phase, .y = birth time, .z = cooling
	// fraction (0 hot → 1 cold), .w = spare. Read in the DRAW shader as
	// INSTANCE_CUSTOM.
	CUSTOM = vec4(rnd(seed), TIME, 0.0, 0.0);
}

void process() {
	vec3 pos = TRANSFORM[3].xyz;
	float t = TIME * turb_speed;

	// --- advect through the curl-noise velocity field (the "fluid") ---
	vec3 field = curl_noise(pos * turb_scale + vec3(0.0, -t, 0.0)) * turbulence;

	// Age tracked manually: born at CUSTOM.y, normalised by the configured LIFETIME.
	float life01 = clamp((TIME - CUSTOM.y) / max(LIFETIME, 0.0001), 0.0, 1.0);
	float heat = 1.0 - life01;

	// --- thrust: keep accelerating ALONG the jet so the flame stays a forward
	//     cone (flamethrower) instead of peeling upward into a sparkler. Fades as
	//     the parcel cools, so the tip of the jet dissolves. ---
	vec3 jdir = normalize((EMISSION_TRANSFORM * vec4(normalize(jet_dir), 0.0)).xyz);
	field += jdir * push * heat;

	// --- buoyancy: optional upward drift for vertical/bonfire spells (low here) ---
	vec3 up = vec3(0.0, 1.0, 0.0);
	field += up * buoyancy * heat;

	// --- swirl: rotate velocity around the world up axis for a vortex column ---
	if (swirl != 0.0) {
		vec3 tang = cross(up, normalize(pos) + vec3(1e-4));
		field += normalize(tang) * swirl;
	}

	// Integrate: accelerate toward the field, then apply drag (viscous damping).
	VELOCITY += field * DELTA;
	VELOCITY *= clamp(1.0 - drag * DELTA, 0.0, 1.0);
	TRANSFORM[3].xyz += VELOCITY * DELTA;

	// Cooling phase stored for the draw shader's colour ramp.
	CUSTOM.z = life01;
}
