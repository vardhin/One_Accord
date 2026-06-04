shader_type sky;
// Drifting procedural cloud sky for One Accord (gl_compatibility friendly).
// Day-sky gradient + sun disk + two layers of fbm noise clouds that slowly drift.

group_uniforms sky;
uniform vec3 sky_top_color : source_color = vec3(0.30, 0.52, 0.85);
uniform vec3 sky_horizon_color : source_color = vec3(0.74, 0.82, 0.90);
uniform vec3 ground_color : source_color = vec3(0.46, 0.50, 0.52);
uniform float horizon_falloff : hint_range(0.0, 8.0) = 3.0;

group_uniforms sun;
uniform vec3 sun_color : source_color = vec3(1.0, 0.96, 0.85);
uniform float sun_size : hint_range(0.0, 0.5) = 0.03;
uniform float sun_blur : hint_range(0.0, 0.5) = 0.12;

group_uniforms clouds;
uniform vec3 cloud_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 cloud_shadow_color : source_color = vec3(0.62, 0.66, 0.74);
uniform float cloud_coverage : hint_range(0.0, 1.0) = 0.5;
uniform float cloud_sharpness : hint_range(1.0, 12.0) = 4.0;
uniform float cloud_scale : hint_range(0.5, 8.0) = 2.2;
uniform vec2 cloud_drift = vec2(0.006, 0.002);
uniform float cloud_opacity : hint_range(0.0, 1.0) = 0.9;

// --- hash / value-noise / fbm ------------------------------------------
float hash(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 5; i++) {
		v += amp * noise(p);
		p *= 2.0;
		amp *= 0.5;
	}
	return v;
}

void sky() {
	vec3 dir = EYEDIR;

	// Vertical gradient: horizon -> top, with a ground hemisphere below.
	float up = clamp(dir.y, -1.0, 1.0);
	vec3 base;
	if (up >= 0.0) {
		float t = pow(1.0 - up, horizon_falloff);
		base = mix(sky_top_color, sky_horizon_color, t);
		// Extra atmospheric haze in the lowest band so distant geometry/fog blends in.
		float haze = pow(1.0 - up, 12.0);
		base = mix(base, sky_horizon_color, haze * 0.5);
	} else {
		base = mix(sky_horizon_color, ground_color, clamp(-up * 2.0, 0.0, 1.0));
	}

	// Sun disk (LIGHT0 is the DirectionalLight3D acting as sun).
	// Crisp core + a faint, tight halo instead of one broad bloom.
	float sun_d = dot(dir, LIGHT0_DIRECTION);
	float sun_core = smoothstep(1.0 - sun_size - sun_blur, 1.0 - sun_size, sun_d);
	float sun_halo = smoothstep(1.0 - sun_size - sun_blur * 2.0, 1.0 - sun_size, sun_d);
	base += sun_color * (sun_core + sun_halo * 0.08) * LIGHT0_ENERGY;

	// Clouds: project the view direction onto a dome plane and sample drifting fbm.
	// Only above the horizon; fade out near it so clouds don't smear into the ground.
	if (up > 0.02) {
		vec2 uv = dir.xz / (up + 0.15);   // simple dome projection
		uv *= cloud_scale;
		uv += TIME * cloud_drift * 10.0;

		float n = fbm(uv);
		n = mix(n, fbm(uv * 2.3 + 5.0), 0.5);  // second octave layer

		// Coverage threshold -> puffy shapes.
		float c = smoothstep(1.0 - cloud_coverage, 1.0, n);
		c = pow(c, cloud_sharpness / 4.0);

		// Fade clouds toward the horizon and by overall opacity.
		float horizon_fade = smoothstep(0.02, 0.25, up);
		c *= horizon_fade * cloud_opacity;

		// Light the cloud: brighter toward the sun side.
		float lit = clamp(sun_d * 0.5 + 0.6, 0.0, 1.0);
		vec3 col = mix(cloud_shadow_color, cloud_color, lit);
		base = mix(base, col, c);
	}

	COLOR = base;
}
