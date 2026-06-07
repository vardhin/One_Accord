@tool
class_name SpellProfile
extends Resource
## One Accord — one spell's visual + behaviour data.
##
## ONE SPELL = ONE .tres. A spell here is "a mesh wrapped in a shader, emitted
## from the sword tip". Because every spell shares the SAME emitter (the muzzle
## Marker3D on the weapon) and the SAME uniform contract, porting a spell is just
## swapping the `shader` + `params` on a new resource — the position/aim work is
## done once in SpellCaster and never repeated per spell.
##
## EMIT MODES
##   PROJECTILE — a tap spawns a mesh that flies forward from the muzzle, lives
##                `lifetime` seconds (or until it travels `max_range`), then dies.
##                (fireball, magic bolt)
##   BEAM       — while the cast key is HELD the spell sustains a stretched mesh
##                from the muzzle forward (channelled). Release ends it. No
##                discrete projectile. (lightning at the sword tip)
##   PLASMA     — a CURL-NOISE FLUID emitter anchored at the muzzle (a
##                PlasmaEmitter node). Tap = one explosive burst of plasma;
##                hold = a sustained jet that keeps releasing while held. The
##                fluid sim variables live on the node as inspector sliders;
##                the `plasma_*` fields below seed its defaults. (fire/plasma,
##                and later wind, with the same module.)
##
## SHADER UNIFORM CONTRACT (every spell shader should declare these so params are
## interchangeable across spells):
##   uniform float time;        // seconds, driven by SpellCaster each frame
##   uniform vec4  color;       // primary tint  (see `color`)
##   uniform vec4  color2;      // secondary tint (see `color2`)
##   uniform float intensity;   // emissive multiplier (see `intensity`)
##   uniform float charge;      // 0..1 channel charge (beams ramp this while held)
## Anything extra a specific shader wants goes in `extra_params`.

enum EmitMode { PROJECTILE, BEAM, PLASMA }

@export_group("Identity")
@export var display_name: String = "Spell"
## Shown in the Dark-Souls spell bar slot. Optional; a coloured dot is drawn if
## absent.
@export var icon: Texture2D

@export_group("Behaviour")
@export var emit_mode: EmitMode = EmitMode.PROJECTILE
## PROJECTILE: forward flight speed (m/s).
@export var projectile_speed: float = 22.0
## PROJECTILE: seconds the projectile lives before despawning.
@export var lifetime: float = 3.0
## PROJECTILE: max metres travelled before despawn (whichever comes first).
@export var max_range: float = 60.0
## BEAM: how far forward from the muzzle the beam reaches (m).
@export var beam_length: float = 14.0
## BEAM: visual thickness of the beam (m).
@export var beam_thickness: float = 0.25

@export_group("Visual")
## The mesh the shader is painted onto. Leave null to use a procedural primitive
## chosen by `primitive` below (the common case — a sphere for orbs, a box for
## beams). Set a PackedScene/Mesh only for bespoke shapes.
@export var mesh: Mesh
## Procedural fallback primitive when `mesh` is null.
@export_enum("Sphere", "Box", "Quad") var primitive: String = "Sphere"
## Uniform scale of the spawned mesh (orb radius feel). Beams scale length via
## `beam_length`; this still sets their cross-section.
@export var scale: float = 0.35
## The spell shader (see the uniform contract in this file's header).
@export var shader: Shader
@export var color: Color = Color(1.0, 0.55, 0.12, 1.0)
@export var color2: Color = Color(1.0, 0.9, 0.4, 1.0)
## Emissive strength fed to the shader's `intensity` uniform.
@export var intensity: float = 3.0
## Optional OmniLight3D so the spell actually lights the world as it flies.
@export var emit_light: bool = true
@export var light_color: Color = Color(1.0, 0.6, 0.2, 1.0)
@export var light_energy: float = 4.0
@export var light_range: float = 6.0
## Any shader-specific uniforms beyond the shared contract (name -> value).
@export var extra_params: Dictionary = {}

@export_group("Plasma (PLASMA mode)")
## PLASMA: a PackedScene whose root is a PlasmaEmitter (the fluid module). The
## caster instances it at the muzzle, then taps it with burst() / holds it with
## set_channelling(). Open this scene and select the root to tweak every fluid
## slider (turbulence, jet_speed, buoyancy, drag, swirl, colours…). If left null
## a default PlasmaEmitter is created with its built-in slider defaults.
@export var plasma_scene: PackedScene


## Build the mesh to paint the shader on. Honours `mesh` if set, else the chosen
## procedural primitive sized by `scale` (beams are stretched by SpellCaster).
func build_mesh() -> Mesh:
	if mesh != null:
		return mesh
	match primitive:
		"Box":
			var b := BoxMesh.new()
			b.size = Vector3.ONE * scale
			return b
		"Quad":
			var q := QuadMesh.new()
			q.size = Vector2(scale, scale)
			return q
		_:
			var s := SphereMesh.new()
			s.radius = scale * 0.5
			s.height = scale
			return s
