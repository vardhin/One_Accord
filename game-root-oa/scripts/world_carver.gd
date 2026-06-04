@tool
extends Node
## One Accord — base-map generator.
##
## Initializes the playable landmass from the design canon
## (Systems-Doc/04-open-world-streaming.md + Documentation/Regions/*):
##   - ~2 km square landmass (a 2x2 grid of 1024 m Terrain3D regions)
##   - base GRASS everywhere (green vertex colour, checker off)
##   - HARD BOUNDARIES: tall mountain walls on the WEST (-X) and SOUTH (-Z) edges
##     (husks never come from these edges — they are the literal bounding geometry)
##   - the broad diagonal WATER channel running west -> lower-east, splitting the
##     lower-left human pocket from the upper/across-water hive side
##   - a gentle grass plain in the human pocket to walk and judge scale on
##
## This is a STARTING SHAPE, not final art. Re-run freely while tuning, then
## hand-sculpt regions on top of it with the Terrain3D brushes.
##
## HOW TO RUN (editor only — needs the Terrain3D editor plugin loaded):
##   1. Open scenes/world.tscn.
##   2. Add this script to a child Node of World (or set `terrain_path` to the
##      Terrain3D node) — or just attach it to World and leave terrain_path empty
##      to auto-find the Terrain3D sibling/child.
##   3. In the Inspector, tick `generate` (a run-once button) — or tick `clear`
##      to wipe all regions first.
##   4. Watch the Output panel; when done it calls save, writing terrain_data/*.res.

# --- Wiring ---------------------------------------------------------------
@export_node_path("Terrain3D") var terrain_path: NodePath

# --- Run buttons (checkboxes that fire once, then untick) -----------------
@export var generate: bool = false: set = _set_generate
@export var clear_first: bool = false: set = _set_clear
## Build the texture set + switch the terrain to the LIT auto-shader.
## Run this ONCE (it fixes the flat/unlit "albedo" look — the colormap debug
## view renders `unshaded`, so it ignores the sun; real textures restore lighting).
@export var setup_textures: bool = false: set = _set_setup_textures

# NOTE: grass is now the Terrain3D particle system (Terrain3DParticles under the
# Terrain3D node in world.tscn), which renders a camera-following grass grid. The
# old instancer-scatter approach lived here and has been removed.

# --- World dimensions (metres) -------------------------------------------
## Half-extent of the playable square. 1024 -> a 2048 m (~2 km) world,
## matching the "~1.5-2 km across" sizing rule.
@export_range(256.0, 4096.0, 64.0) var world_half_size: float = 1024.0

# --- Heights (metres) -----------------------------------------------------
@export var plain_height: float = 3.0          ## grass plain baseline
@export var mountain_height: float = 120.0     ## peak of the edge walls
@export var water_floor: float = -8.0          ## bottom of the water channel
@export var sea_level: float = 0.0             ## reference for "below = water"

# --- Boundary shaping -----------------------------------------------------
## How far in from the W/S edges the mountains ramp up (metres).
@export var mountain_band: float = 320.0
## Half-width of the diagonal water channel (metres).
@export var water_half_width: float = 110.0
## Diagonal direction the water runs (west -> lower-east). Normalized in code.
@export var water_dir: Vector2 = Vector2(1.0, 0.45)
## Perpendicular offset of the water centreline from world centre (metres);
## negative pushes the channel toward lower-left so the human pocket is below it.
@export var water_offset: float = -120.0

# --- Surface colours ------------------------------------------------------
@export var grass_color: Color = Color(0.33, 0.49, 0.22)   ## plain green
@export var rock_color: Color = Color(0.42, 0.40, 0.38)    ## mountain grey
@export var sand_color: Color = Color(0.55, 0.52, 0.40)    ## shoreline
@export var water_bed_color: Color = Color(0.20, 0.30, 0.34)

var _noise := FastNoiseLite.new()


func _set_generate(v: bool) -> void:
	generate = false
	if v and Engine.is_editor_hint():
		_generate()


func _set_clear(v: bool) -> void:
	clear_first = false
	if v and Engine.is_editor_hint():
		var t := _terrain()
		if t:
			_clear(t)


func _set_setup_textures(v: bool) -> void:
	setup_textures = false
	if v and Engine.is_editor_hint():
		_setup_textures()


func _terrain() -> Terrain3D:
	# Explicit path wins; otherwise search the parent (World) for a Terrain3D.
	if terrain_path and not terrain_path.is_empty():
		var n := get_node_or_null(terrain_path)
		if n is Terrain3D:
			return n
	var parent := get_parent()
	if parent:
		if parent is Terrain3D:
			return parent
		for c in parent.get_children():
			if c is Terrain3D:
				return c
	for c in get_children():
		if c is Terrain3D:
			return c
	push_error("world_carver: no Terrain3D node found. Set `terrain_path`.")
	return null


func _clear(t: Terrain3D) -> void:
	var data := t.get_data()
	for loc in data.get_region_locations():
		data.remove_regionl(loc)
	data.update_maps()
	print("world_carver: cleared all regions.")


## Build a 2-texture set (ground + rock) from Terrain3D's bundled demo textures
## and switch the material to the LIT auto-shader. This replaces the unlit
## colormap debug view (`render_mode unshaded`) that made the terrain look flat
## and ignore the sun. The colour map still tints the lit albedo.
func _setup_textures() -> void:
	var t := _terrain()
	if t == null:
		return

	const TEX_DIR := "res://demo/assets/textures/"
	var sets := [
		{
			"name": "ground", "id": 0, "uv": 0.08,
			"alb": TEX_DIR + "ground037_alb_ht.png",
			"nrm": TEX_DIR + "ground037_nrm_rgh.png",
			"tint": Color(0.85, 0.95, 0.78),  # nudge ground toward grass-green
		},
		{
			"name": "rock", "id": 1, "uv": 0.05,
			"alb": TEX_DIR + "rock023_alb_ht.png",
			"nrm": TEX_DIR + "rock023_nrm_rgh.png",
			"tint": Color(1, 1, 1),
		},
	]

	var list: Array[Terrain3DTextureAsset] = []
	for s in sets:
		var alb := load(s["alb"]) as Texture2D
		var nrm := load(s["nrm"]) as Texture2D
		if alb == null or nrm == null:
			push_error("world_carver: missing texture %s / %s" % [s["alb"], s["nrm"]])
			return
		var ta := Terrain3DTextureAsset.new()
		ta.set_name(s["name"])
		ta.set_id(s["id"])
		ta.set_albedo_texture(alb)
		ta.set_normal_texture(nrm)
		ta.set_albedo_color(s["tint"])
		ta.set_uv_scale(s["uv"])
		list.append(ta)

	var assets := t.get_assets()
	if assets == null:
		assets = Terrain3DAssets.new()
		t.set_assets(assets)
	assets.set_texture_list(list)

	# Switch the material to the lit, auto-textured path.
	# NOTE: auto_base/overlay_texture index by texture-list POSITION, not by the
	# `id` field. With grass at list index 0 and rock at 1, the base must point at
	# the GRASS list slot — empirically that is index 1 here (rock on slopes = 0).
	# Verified by rendering; do not "tidy" these back to 0/1 without re-checking.
	var mat := t.get_material()
	if mat:
		mat.set_show_checkered(false)
		mat.set_show_colormap(false)   # turn OFF the unlit debug view
		mat.set_auto_shader(true)      # auto-texture by slope, fully lit
		mat.set_world_background(1)
		mat.set_shader_param("auto_base_texture", 1)     # grass on flats
		mat.set_shader_param("auto_overlay_texture", 0)  # rock on slopes
		mat.set_shader_param("auto_slope", 3.0)
		mat.set_shader_param("auto_height_reduction", 0.0)
	print("world_carver: textures set up, auto-shader ON (grass base, rock slopes), lit.")


func _generate() -> void:
	var t := _terrain()
	if t == null:
		return

	if clear_first:
		_clear(t)

	# Just turn off the magenta debug checker. Do NOT force the colormap debug
	# view here — that path renders `unshaded` (flat, ignores the sun). Once
	# `setup_textures` has run, the material is on the lit auto-shader and the
	# carved colours tint it; regenerating must not knock it back to unlit.
	var mat := t.get_material()
	if mat:
		mat.set_show_checkered(false)
		mat.set_world_background(1)  # 1 = FLAT (flat skirt beyond the regions)

	var region_size: float = float(t.get_region_size())  # world metres per region
	var data := t.get_data()

	# 1) Instantiate every region tile the playable square touches, so there is
	#    actual terrain to write into ("carving" the macro footprint).
	var half := world_half_size
	var loc := -half
	while loc <= half:
		var lz := -half
		while lz <= half:
			# add_region_blankp takes a global position; Terrain3D maps it to the
			# owning region tile and creates it if absent.
			data.add_region_blankp(Vector3(loc, 0.0, lz), false)
			lz += region_size
		loc += region_size
	# also stamp the far corner explicitly
	data.add_region_blankp(Vector3(half, 0.0, half), false)

	_noise.seed = 1337
	_noise.frequency = 0.0025
	_noise.fractal_octaves = 4

	var wdir := water_dir.normalized()
	# Perpendicular to the water direction: signed distance to the channel centre.
	var wperp := Vector2(-wdir.y, wdir.x)

	# 2) Write height + colour at EVERY heightmap vertex.
	#
	#    CRITICAL: the heightmap has one vertex every `vertex_spacing` metres
	#    (default 1 m). We MUST step the loop by that spacing — sampling coarser
	#    (e.g. every 8 m) writes one tall value and leaves the in-between vertices
	#    at 0, which renders as a field of isolated spikes. Step == spacing makes
	#    it a continuous surface.
	var step: float = maxf(t.get_vertex_spacing(), 1.0)
	var steps := 0
	var x := -half
	while x <= half:
		var z := -half
		while z <= half:
			var p := Vector3(x, 0.0, z)
			var h := _height_at(x, z, half, wperp)
			data.set_height(p, h)
			data.set_color(p, _color_for(h))
			z += step
			steps += 1
		x += step

	# 3) Recompute ranges and refresh, then persist to terrain_data/.
	#    Leave the world background and sky alone — killing the background plus
	#    fog turns the scene into a black void.
	data.calc_height_range()
	data.update_maps()

	var dir := t.get_data_directory()
	data.save_directory(dir)
	print("world_carver: generated %d regions, wrote %d points to %s" % [
		data.get_region_count(), steps, dir])


## Signed perpendicular distance from (x,z) to the water centreline.
func _water_dist(x: float, z: float, wperp: Vector2) -> float:
	return Vector2(x, z).dot(wperp) - water_offset


func _height_at(x: float, z: float, half: float, wperp: Vector2) -> float:
	var h := plain_height + _noise.get_noise_2d(x, z) * 6.0

	# WEST edge wall (-X) and SOUTH edge wall (-Z): ramp up toward the boundary.
	var west := clampf((-(x) - (half - mountain_band)) / mountain_band, 0.0, 1.0)
	var south := clampf((-(z) - (half - mountain_band)) / mountain_band, 0.0, 1.0)
	var wall := maxf(_smooth(west), _smooth(south))
	if wall > 0.0:
		var ridge := _noise.get_noise_2d(x * 1.7, z * 1.7) * 40.0
		h = lerpf(h, mountain_height + ridge, wall)

	# DIAGONAL water channel: gouge below sea level near the centreline.
	var d := absf(_water_dist(x, z, wperp))
	if d < water_half_width:
		var t := _smooth(1.0 - d / water_half_width)  # 1 at centre -> 0 at bank
		# Don't drown the mountains; water only cuts where the land is low-ish.
		var carve := minf(h, water_floor)
		h = lerpf(h, carve, t * (1.0 - wall))

	return h


func _color_for(h: float) -> Color:
	if h <= sea_level + 1.0:
		return water_bed_color
	if h <= sea_level + 5.0:
		return sand_color
	if h >= mountain_height * 0.45:
		return rock_color
	return grass_color


## Smoothstep-ish easing for nicer ramps than a linear clamp.
func _smooth(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
