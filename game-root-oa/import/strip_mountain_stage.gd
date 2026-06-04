@tool
extends EditorScenePostImport
## Strip cameras/lights that shipped inside scenery FBXs, then apply world rock.

const ROCK_ALBEDO := "res://demo/assets/textures/rock023_alb_ht.png"
const ROCK_NORMAL := "res://demo/assets/textures/rock023_nrm_rgh.png"


func _post_import(scene: Node) -> Object:
	var rock := _rock_material()
	_clean_scene(scene, rock)
	return scene


func _clean_scene(node: Node, rock: Material) -> void:
	for child in node.get_children():
		_clean_scene(child, rock)
		if child is Camera3D or child is Light3D:
			child.get_parent().remove_child(child)
			child.free()
		elif child is MeshInstance3D:
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
