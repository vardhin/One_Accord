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

var _muzzle: Marker3D                 ## emitter transform (sword tip), set by player
var _projectiles: Array = []          ## [{node, vel, life, age, travelled, mat, light}]
var _beam: MeshInstance3D             ## the live channelled beam (null when idle)
var _beam_mat: ShaderMaterial
var _beam_profile: SpellProfile
var _beam_charge: float = 0.0
var _time: float = 0.0


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
	if _beam and is_instance_valid(_beam):
		_beam.queue_free()
	_beam = null
	_beam_mat = null
	_beam_profile = null
	_beam_charge = 0.0


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
	return inst


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
