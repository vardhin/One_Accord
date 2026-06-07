extends Node
## One Accord — spell VFX emitter. Spawns the "mesh + shader" for a SpellProfile
## from the weapon's muzzle Marker3D and drives it.
##
## PORTABILITY: this node knows nothing about any specific spell. It reads a
## SpellProfile, builds the mesh, attaches the profile's shader, and either
## launches a projectile or sustains a beam. The muzzle (where things spawn) is a
## single Marker3D resolved once from the player, so a new spell is purely a new
## .tres — position/aim are never re-solved per spell.
##
## The player drives it through three calls:
##   cast_projectile(profile)      — tap: fire one shot forward from the muzzle.
##   begin_beam(profile)           — hold: start/keep a channelled beam.
##   end_beam()                    — release: tear the beam down.
## plus set_muzzle(marker) once the weapon is attached.

const FIRE_PARTICLE_SHADER := preload("res://shaders/fire_particle.gdshader")

var _muzzle: Marker3D                 ## emitter transform (sword tip), set by player
var _projectiles: Array = []          ## [{node, vel, life, age, travelled, mat, light}]
var _beam: MeshInstance3D             ## the live channelled beam (null when idle)
var _beam_mat: ShaderMaterial
var _beam_profile: SpellProfile
var _beam_charge: float = 0.0
var _time: float = 0.0

var _plasma: PlasmaEmitter             ## the live muzzle-anchored plasma emitter (null when idle)
var _plasma_profile: SpellProfile


func set_muzzle(marker: Marker3D) -> void:
	_muzzle = marker


func has_muzzle() -> bool:
	return _muzzle != null and is_instance_valid(_muzzle)


# ── Projectiles (tap) ──────────────────────────────────────────────────────
## Spawn one projectile that flies forward (the muzzle's -Z) and despawns on
## lifetime / range. Lives in the world so it keeps flying after the player moves.
func cast_projectile(profile: SpellProfile) -> void:
	if profile == null or not has_muzzle():
		return
	if profile.emit_mode == SpellProfile.EmitMode.PLASMA:
		_plasma_for(profile).burst()           # tap = one explosive plasma release
		return
	var xf := _muzzle.global_transform
	var inst := _make_spell_mesh(profile)
	_spawn_root().add_child(inst)
	inst.global_transform = xf

	var mat: ShaderMaterial = inst.get_meta("mat")
	var light: OmniLight3D = inst.get_meta("light") if inst.has_meta("light") else null
	var forward: Vector3 = -xf.basis.z.normalized()
	_projectiles.append({
		"node": inst, "vel": forward * profile.projectile_speed,
		"life": profile.lifetime, "age": 0.0, "travelled": 0.0,
		"max_range": profile.max_range, "mat": mat, "light": light,
	})


# ── Beam (hold to channel) ─────────────────────────────────────────────────
## Start the channelled beam for `profile` (or keep the existing one alive). The
## beam is a stretched box parented to the muzzle so it tracks the sword tip; its
## `charge` uniform ramps up while held.
func begin_beam(profile: SpellProfile) -> void:
	if profile == null or not has_muzzle():
		return
	if profile.emit_mode == SpellProfile.EmitMode.PLASMA:
		_plasma_for(profile).set_channelling(true)   # hold = sustained plasma jet
		return
	if _beam and is_instance_valid(_beam) and _beam_profile == profile:
		return                                  # already channelling this one
	end_beam()
	_beam_profile = profile
	_beam_charge = 0.0

	var inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	# Unit box: long axis Z (shader runs the bolt along local Z), thin X/Y.
	box.size = Vector3(profile.beam_thickness, profile.beam_thickness, profile.beam_length)
	inst.mesh = box
	# Offset so the near face sits at the muzzle and the beam extends out along -Z.
	inst.position = Vector3(0.0, 0.0, -profile.beam_length * 0.5)

	_beam_mat = _make_material(profile)
	inst.material_override = _beam_mat
	inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_muzzle.add_child(inst)
	_beam = inst

	if profile.emit_light:
		var l := _make_light(profile)
		inst.add_child(l)


func end_beam() -> void:
	if _plasma and is_instance_valid(_plasma):
		_plasma.set_channelling(false)          # stop the plasma jet (parcels live out)
	if _beam and is_instance_valid(_beam):
		_beam.queue_free()
	_beam = null
	_beam_mat = null
	_beam_profile = null
	_beam_charge = 0.0


## Resolve (lazily create) the muzzle-anchored PlasmaEmitter for a PLASMA spell.
## Instances the profile's plasma_scene if set, else a default PlasmaEmitter; the
## emitter is parented to the muzzle so its jet follows the sword tip. Rebuilds if
## the active plasma spell changed (1/2/3 switch).
func _plasma_for(profile: SpellProfile) -> PlasmaEmitter:
	if _plasma and is_instance_valid(_plasma) and _plasma_profile == profile:
		return _plasma
	if _plasma and is_instance_valid(_plasma):
		_plasma.queue_free()
	var e: PlasmaEmitter
	if profile.plasma_scene != null:
		var inst := profile.plasma_scene.instantiate()
		e = inst if inst is PlasmaEmitter else PlasmaEmitter.new()
		if not (inst is PlasmaEmitter):
			inst.queue_free()
	else:
		e = PlasmaEmitter.new()
	_muzzle.add_child(e)
	_plasma = e
	_plasma_profile = profile
	return e


func beam_active() -> bool:
	return _beam != null and is_instance_valid(_beam)


# ── Per-frame drive ────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	_time += delta

	# Advance + retire projectiles.
	var i := _projectiles.size() - 1
	while i >= 0:
		var p: Dictionary = _projectiles[i]
		var node: Node3D = p["node"]
		if not is_instance_valid(node):
			_projectiles.remove_at(i)
			i -= 1
			continue
		var step: Vector3 = p["vel"] * delta
		node.global_position += step
		p["age"] += delta
		p["travelled"] += step.length()
		(p["mat"] as ShaderMaterial).set_shader_parameter("time", _time)
		if p["age"] >= p["life"] or p["travelled"] >= p["max_range"]:
			node.queue_free()
			_projectiles.remove_at(i)
		i -= 1

	# Drive the beam: ramp charge while held, push time + charge to the shader.
	if beam_active() and _beam_mat:
		_beam_charge = minf(1.0, _beam_charge + delta * 1.5)
		_beam_mat.set_shader_parameter("time", _time)
		_beam_mat.set_shader_parameter("charge", _beam_charge)


# ── Mesh / material construction ───────────────────────────────────────────
func _make_spell_mesh(profile: SpellProfile) -> MeshInstance3D:
	var inst := MeshInstance3D.new()
	inst.mesh = profile.build_mesh()
	var mat := _make_material(profile)
	inst.material_override = mat
	inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	inst.set_meta("mat", mat)
	if profile.emit_light:
		var l := _make_light(profile)
		inst.add_child(l)
		inst.set_meta("light", l)
	_attach_fire_particles(inst, profile)
	return inst


# ── Fire particles (this is what makes it read as FIRE, not a glowing ball) ──
## Bolts the actual fire onto a projectile: a roiling flame body, fast scattering
## embers/sparks, a trailing smoke wisp, and a one-shot launch burst. Everything
## is built procedurally so a spell stays a single .tres with no scene deps, and
## stays inside the gl_compatibility feature set (GPUParticles3D + simple process
## materials are supported there). Colours come from the profile so any fire-ish
## spell reuses this for free.
func _attach_fire_particles(parent: Node3D, profile: SpellProfile) -> void:
	var s: float = maxf(profile.scale, 0.1)
	var hot := profile.color2          # white/yellow hot
	var flame := profile.color         # orange flame
	var ember := Color(1.0, 0.35, 0.08) # deep ember/red

	# 1) FLAME BODY — big soft additive puffs licking off the core.
	parent.add_child(_make_fire_emitter({
		"amount": 64,
		"lifetime": 0.55,
		"size_min": s * 0.9, "size_max": s * 1.8,
		"sphere_radius": s * 0.45,
		"vel_min": 0.4, "vel_max": 1.2,
		"spread_dir": Vector3.ZERO,           # radial, no bias
		"gravity": Vector3(0, 1.4, 0),        # heat rises
		"damping": 1.5,
		"scale_curve": [1.4, 0.0],            # grow-then-shrink feel via initial size + damping
		"softness": 2.2, "intensity": 2.0,
		"c0": hot, "c1": flame, "c2": ember, "c3": Color(ember.r, ember.g, ember.b, 0.0),
	}))

	# 2) EMBERS / SPARKS — small, fast, bright; this gives the explosive crackle.
	parent.add_child(_make_fire_emitter({
		"amount": 90,
		"lifetime": 0.7,
		"size_min": s * 0.12, "size_max": s * 0.28,
		"sphere_radius": s * 0.3,
		"vel_min": 2.5, "vel_max": 6.0,
		"spread_dir": Vector3.ZERO,
		"gravity": Vector3(0, -2.0, 0),       # sparks arc and fall
		"damping": 0.6,
		"softness": 3.5, "intensity": 3.2,
		"c0": Color(1.0, 0.98, 0.85), "c1": hot, "c2": ember, "c3": Color(0.3, 0.05, 0.0, 0.0),
	}))

	# 3) SMOKE WISP — dark, slow, trailing; reads as heat-haze behind the orb.
	parent.add_child(_make_fire_emitter({
		"amount": 28,
		"lifetime": 1.1,
		"size_min": s * 1.2, "size_max": s * 2.4,
		"sphere_radius": s * 0.35,
		"vel_min": 0.2, "vel_max": 0.8,
		"spread_dir": Vector3.ZERO,
		"gravity": Vector3(0, 0.8, 0),
		"damping": 1.0,
		"softness": 1.6, "intensity": 0.5,
		"c0": Color(0.25, 0.12, 0.08, 0.6), "c1": Color(0.12, 0.08, 0.07, 0.4),
		"c2": Color(0.05, 0.04, 0.04, 0.15), "c3": Color(0.0, 0.0, 0.0, 0.0),
	}))


## Build one GPUParticles3D fire layer from a config dict (see _attach_fire_particles).
func _make_fire_emitter(cfg: Dictionary) -> GPUParticles3D:
	var em := GPUParticles3D.new()
	em.amount = cfg["amount"]
	em.lifetime = cfg["lifetime"]
	em.local_coords = false               # particles trail in world space behind the moving orb
	em.fixed_fps = 30
	em.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Process material: spherical emission, outward velocity, gentle gravity, and a
	# colour ramp over life from white-hot to ember/smoke.
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = cfg["sphere_radius"]
	pm.direction = Vector3(0, 0, 0)
	pm.spread = 180.0
	pm.initial_velocity_min = cfg["vel_min"]
	pm.initial_velocity_max = cfg["vel_max"]
	pm.gravity = cfg["gravity"]
	pm.damping_min = cfg["damping"]
	pm.damping_max = cfg["damping"]
	pm.angle_min = -180.0
	pm.angle_max = 180.0

	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.35, 0.7, 1.0])
	ramp.colors = PackedColorArray([cfg["c0"], cfg["c1"], cfg["c2"], cfg["c3"]])
	var tex := GradientTexture1D.new()
	tex.gradient = ramp
	pm.color_ramp = tex

	# Shrink over life so puffs dissipate.
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 1.0))
	sc.add_point(Vector2(1.0, 0.0))
	var sct := CurveTexture.new()
	sct.curve = sc
	pm.scale_curve = sct
	pm.scale_min = cfg["size_min"]
	pm.scale_max = cfg["size_max"]

	em.process_material = pm

	# Draw pass: a billboarded quad with the additive fire shader.
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var mat := ShaderMaterial.new()
	mat.shader = FIRE_PARTICLE_SHADER
	mat.set_shader_parameter("softness", cfg["softness"])
	mat.set_shader_parameter("intensity", cfg["intensity"])
	quad.surface_set_material(0, mat)
	em.draw_pass_1 = quad

	return em


func _make_material(profile: SpellProfile) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = profile.shader
	# Shared uniform contract.
	mat.set_shader_parameter("time", _time)
	mat.set_shader_parameter("color", profile.color)
	mat.set_shader_parameter("color2", profile.color2)
	mat.set_shader_parameter("intensity", profile.intensity)
	mat.set_shader_parameter("charge", 0.0)
	# Per-spell extras.
	for key in profile.extra_params:
		mat.set_shader_parameter(key, profile.extra_params[key])
	return mat


func _make_light(profile: SpellProfile) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.light_color = profile.light_color
	l.light_energy = profile.light_energy
	l.omni_range = profile.light_range
	l.shadow_enabled = false
	return l


## Where projectiles live: the current scene root, so they persist independent of
## the player's movement. Falls back to this node's tree if needed.
func _spawn_root() -> Node:
	var scn := get_tree().current_scene
	return scn if scn else get_tree().root
