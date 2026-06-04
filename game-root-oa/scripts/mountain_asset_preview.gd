@tool
extends Node3D
## Keeps imported mountain meshes sitting above the Terrain3D surface.

const ROCK_ALBEDO := "res://demo/assets/textures/rock023_alb_ht.png"
const ROCK_NORMAL := "res://demo/assets/textures/rock023_nrm_rgh.png"

@export_node_path("Terrain3D") var terrain_path: NodePath = NodePath("../Terrain3D")
@export var apply_rock_material: bool = true
@export var lift_above_terrain: bool = true
@export var terrain_clearance: float = 6.0
@export var snap_on_ready: bool = true
@export var snap_now: bool = false:
	set(value):
		snap_now = false
		if value:
			call_deferred("_refresh_mountains")


func _ready() -> void:
	if snap_on_ready:
		call_deferred("_refresh_mountains")


func _refresh_mountains() -> void:
	if apply_rock_material:
		_apply_rock_materials()
	_lift_children_above_terrain()


func _apply_rock_materials() -> void:
	var rock := _rock_material()
	for child in _walk(self):
		if child is MeshInstance3D:
			child.material_override = rock
			child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


func _rock_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.resource_name = "MountainRock"
	mat.albedo_texture = load(ROCK_ALBEDO)
	mat.normal_enabled = true
	mat.normal_texture = load(ROCK_NORMAL)
	mat.roughness = 0.86
	mat.uv1_scale = Vector3(0.08, 0.08, 0.08)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return mat


func _lift_children_above_terrain() -> void:
	if not lift_above_terrain:
		return

	var terrain := _terrain()
	if terrain == null or terrain.data == null:
		return

	for child in get_children():
		if child is Node3D:
			_lift_child(child, terrain)


func _lift_child(child: Node3D, terrain: Terrain3D) -> void:
	var bounds := _combined_aabb(child)
	if bounds.size == Vector3.ZERO:
		return

	var terrain_height := _max_terrain_height_under(bounds, terrain)
	if is_nan(terrain_height):
		return

	var lift := terrain_height + terrain_clearance - bounds.position.y
	if lift > 0.01:
		var p := child.global_position
		p.y += lift
		child.global_position = p


func _terrain() -> Terrain3D:
	if not terrain_path.is_empty():
		var node := get_node_or_null(terrain_path)
		if node is Terrain3D:
			return node
	for sibling in get_parent().get_children():
		if sibling is Terrain3D:
			return sibling
	return null


func _max_terrain_height_under(bounds: AABB, terrain: Terrain3D) -> float:
	var min_x := bounds.position.x
	var max_x := bounds.position.x + bounds.size.x
	var min_z := bounds.position.z
	var max_z := bounds.position.z + bounds.size.z
	var center := bounds.get_center()
	var samples := [
		Vector3(center.x, 0.0, center.z),
		Vector3(min_x, 0.0, min_z),
		Vector3(min_x, 0.0, max_z),
		Vector3(max_x, 0.0, min_z),
		Vector3(max_x, 0.0, max_z),
		Vector3(center.x, 0.0, min_z),
		Vector3(center.x, 0.0, max_z),
		Vector3(min_x, 0.0, center.z),
		Vector3(max_x, 0.0, center.z),
	]

	var max_height := -INF
	var found := false
	for sample in samples:
		var h: float = terrain.data.get_height(sample)
		if not is_nan(h):
			max_height = maxf(max_height, h)
			found = true
	return max_height if found else NAN


func _combined_aabb(node: Node3D) -> AABB:
	var has_bounds := false
	var combined := AABB()
	for child in _walk(node):
		if child is MeshInstance3D and child.mesh != null:
			var mesh_bounds := _global_aabb(child, child.get_aabb())
			if has_bounds:
				combined = combined.merge(mesh_bounds)
			else:
				combined = mesh_bounds
				has_bounds = true
	return combined


func _walk(node: Node) -> Array[Node]:
	var nodes: Array[Node] = [node]
	for child in node.get_children():
		nodes.append_array(_walk(child))
	return nodes


func _global_aabb(node: Node3D, bounds: AABB) -> AABB:
	var min_v := Vector3(INF, INF, INF)
	var max_v := Vector3(-INF, -INF, -INF)
	for x in [bounds.position.x, bounds.position.x + bounds.size.x]:
		for y in [bounds.position.y, bounds.position.y + bounds.size.y]:
			for z in [bounds.position.z, bounds.position.z + bounds.size.z]:
				var p := node.global_transform * Vector3(x, y, z)
				min_v = min_v.min(p)
				max_v = max_v.max(p)
	return AABB(min_v, max_v - min_v)
