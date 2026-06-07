@tool
class_name PlasmaEmitter
extends GPUParticles3D
## One Accord — PLASMA / FLUID emitter (the reusable "fluid module").
## =============================================================================
## A GPUParticles3D whose motion is a CURL-NOISE FLUID FIELD (see
## shaders/plasma_process.gdshader). Each particle is a parcel of plasma advected
## through a divergence-free velocity field + buoyancy + drag — the real-time
## stand-in for a fluid solver on the gl_compatibility renderer (no compute
## shaders → no grid/SPH solver available, so we advect parcels through a
## procedural field instead, which is what makes it read as a FLUID).
##
## Every sim variable below is an inspector slider; editing it live re-pushes the
## matching shader uniform, so you can dial laminar↔turbulent, jet speed,
## buoyancy, drag, swirl, colours, etc. right in the editor (works in-editor too,
## via @tool).
##
## USAGE (from SpellCaster):
##   var e := PlasmaEmitter.new(); add as child of the muzzle
##   e.burst()                 # tap: one explosive plasma release
##   e.set_channelling(true)   # hold: sustained jet; false to stop
## A wind spell later is the SAME node with buoyancy≈0, cool colours, high drag.

const PROCESS_SHADER := preload("res://shaders/plasma_process.gdshader")
const DRAW_SHADER := preload("res://shaders/plasma_draw.gdshader")

# ── Emission / source ─────────────────────────────────────────────────────
@export_group("Source")
## Particles spawned per second while channelling (the jet density).
@export_range(0.0, 4000.0, 1.0) var channel_rate: float = 800.0
## Particles fired in one tap burst (the explosive release).
@export_range(0.0, 2000.0, 1.0) var burst_count: float = 400.0
## Radius of the sphere at the muzzle that parcels spawn within.
@export_range(0.0, 1.0, 0.01) var emit_radius: float = 0.12
## Seconds each parcel lives (longer = taller flame / longer trail).
@export_range(0.1, 6.0, 0.05) var parcel_life: float = 1.1
## Size of each parcel billboard.
@export_range(0.01, 2.0, 0.01) var parcel_size: float = 0.35

# ── Jet (the "release" along the sword's aim) ─────────────────────────────
@export_group("Jet")
## Local-space jet direction (sword forward is -Z). Normalised in-shader.
@export var jet_dir: Vector3 = Vector3(0, 0, -1)
## Initial speed along the jet — how hard plasma is ejected.
@export_range(0.0, 30.0, 0.1) var jet_speed: float = 7.0
## 0 = perfectly LAMINAR jet (a clean column), 1 = wide turbulent cone.
@export_range(0.0, 1.0, 0.01) var jet_spread: float = 0.22
## Extra omnidirectional speed added on a tap burst — the explosion pop.
@export_range(0.0, 30.0, 0.1) var burst_speed: float = 9.0

# ── Fluid field ───────────────────────────────────────────────────────────
@export_group("Fluid")
## Curl-noise swirl strength. LOW = smooth laminar flow, HIGH = chaotic,
## explosive, turbulent fire. This is the headline "how fiery" knob.
@export_range(0.0, 20.0, 0.05) var turbulence: float = 6.0
## Spatial frequency of the eddies (big rolls vs fine shredding).
@export_range(0.1, 10.0, 0.05) var turb_scale: float = 2.4
## How fast the eddy field evolves over time.
@export_range(0.0, 8.0, 0.05) var turb_speed: float = 1.6
## Thrust ALONG the jet — keeps the flame a forward cone (flamethrower). This is
## the headline "reach" of the jet. Fades as parcels cool, so the tip dissolves.
@export_range(0.0, 40.0, 0.1) var push: float = 10.0
## Upward acceleration — hot plasma rises. Keep low for a forward jet; raise it
## (and drop push) for a vertical bonfire/torch spell.
@export_range(-10.0, 20.0, 0.1) var buoyancy: float = 0.5
## Velocity damping (viscosity-ish). Higher = parcels slow faster.
@export_range(0.0, 6.0, 0.05) var drag: float = 1.3
## Rotation around the up axis — turns the column into a vortex.
@export_range(0.0, 10.0, 0.05) var swirl: float = 0.0

# ── Look ──────────────────────────────────────────────────────────────────
@export_group("Look")
@export var col_hot: Color = Color(1.0, 0.98, 0.85)
@export var col_mid: Color = Color(1.0, 0.55, 0.12)
@export var col_cool: Color = Color(0.7, 0.08, 0.02)
@export var col_smoke: Color = Color(0.05, 0.04, 0.04)
@export_range(0.0, 12.0, 0.1) var intensity: float = 3.2
@export_range(0.5, 8.0, 0.1) var softness: float = 2.6
@export_range(0.0, 2.0, 0.01) var flicker: float = 0.6

var _proc: ShaderMaterial
var _draw: ShaderMaterial


func _ready() -> void:
	_build()
	# Idle by default; SpellCaster calls burst()/set_channelling().
	if not Engine.is_editor_hint():
		emitting = false


## (Re)build the particle stack. Safe to call repeatedly.
func _build() -> void:
	local_coords = false                       # parcels trail in world space
	fixed_fps = 30
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	lifetime = parcel_life
	amount = int(maxf(burst_count, channel_rate * parcel_life)) # pool big enough for both modes
	one_shot = false
	explosiveness = 0.0

	_proc = ShaderMaterial.new()
	_proc.shader = PROCESS_SHADER
	process_material = _proc

	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * parcel_size
	_draw = ShaderMaterial.new()
	_draw.shader = DRAW_SHADER
	quad.surface_set_material(0, _draw)
	draw_pass_1 = quad

	_push_all()


## Push every slider into the two shaders. Called on build + whenever a slider
## changes (so editor tweaks are live).
func _push_all() -> void:
	if _proc == null:
		return
	_proc.set_shader_parameter("emit_radius", emit_radius)
	_proc.set_shader_parameter("jet_dir", jet_dir)
	_proc.set_shader_parameter("jet_speed", jet_speed)
	_proc.set_shader_parameter("jet_spread", jet_spread)
	_proc.set_shader_parameter("burst_speed", 0.0)   # set per-burst in burst()
	_proc.set_shader_parameter("turbulence", turbulence)
	_proc.set_shader_parameter("turb_scale", turb_scale)
	_proc.set_shader_parameter("turb_speed", turb_speed)
	_proc.set_shader_parameter("push", push)
	_proc.set_shader_parameter("buoyancy", buoyancy)
	_proc.set_shader_parameter("drag", drag)
	_proc.set_shader_parameter("swirl", swirl)

	_draw.set_shader_parameter("col_hot", col_hot)
	_draw.set_shader_parameter("col_mid", col_mid)
	_draw.set_shader_parameter("col_cool", col_cool)
	_draw.set_shader_parameter("col_smoke", col_smoke)
	_draw.set_shader_parameter("intensity", intensity)
	_draw.set_shader_parameter("softness", softness)
	_draw.set_shader_parameter("flicker", flicker)

	lifetime = parcel_life
	if draw_pass_1 is QuadMesh:
		(draw_pass_1 as QuadMesh).size = Vector2.ONE * parcel_size


func _process(_dt: float) -> void:
	# In the editor, keep uniforms synced to sliders so tweaks show immediately.
	if Engine.is_editor_hint():
		if _proc == null:
			_build()
		_push_all()
		emitting = true


# ── Public API for SpellCaster ─────────────────────────────────────────────
## One explosive release (tap). Fires the whole pool once with an added radial
## burst speed, then GPUParticles3D auto-stops (one_shot). NOTE: `amount` is fixed
## at build — changing it at runtime reallocates the buffer and clears particles,
## which is what made bursts intermittently invisible.
func burst() -> void:
	if _proc == null:
		_build()
	_proc.set_shader_parameter("burst_speed", burst_speed)
	one_shot = true
	explosiveness = 1.0     # all parcels at once = an actual explosion, not a dribble
	emitting = false        # disarm so restart() begins a clean single shot
	restart()               # restart() re-arms emission for the one_shot cycle


## Sustained jet (hold). True = keep releasing plasma along the jet; false = stop.
func set_channelling(on: bool) -> void:
	if _proc == null:
		_build()
	if on:
		_proc.set_shader_parameter("burst_speed", 0.0)
		one_shot = false
		explosiveness = 0.0  # steady stream for a sustained jet
		emitting = true      # continuous: just arm emission (amount is fixed)
	else:
		emitting = false
