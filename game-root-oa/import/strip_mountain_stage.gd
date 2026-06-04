@tool
extends EditorScenePostImport
## Strip cameras and lights that shipped inside scenery FBXs.


func _post_import(scene: Node) -> Object:
	_remove_stage_nodes(scene)
	return scene


func _remove_stage_nodes(node: Node) -> void:
	for child in node.get_children():
		_remove_stage_nodes(child)
		if child is Camera3D or child is Light3D:
			child.get_parent().remove_child(child)
			child.free()
