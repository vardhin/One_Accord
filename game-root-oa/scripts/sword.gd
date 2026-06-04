@tool
extends Node3D
## One Accord — placeholder procedural sword.
##
## Builds a simple longsword out of boxes (blade + fuller-ish bevel, crossguard,
## grip, pommel) entirely in code so we have SOMETHING to hold today, with zero
## art assets. Swap this whole node for a real weapon mesh later — the combat
## rig attaches by node, not by knowing anything about this geometry.
##
## Local orientation: the blade points along +Y (up), so when this is parented
## to a hand BoneAttachment3D the grip sits at the origin and the blade extends
## out of the fist. Tweak `grip_transform` on the attachment to fit the hand.

@export var blade_length: float = 0.95
@export var blade_width: float = 0.06
@export var blade_thickness: float = 0.012
@export var guard_width: float = 0.20
@export var grip_length: float = 0.16
@export var steel_color: Color = Color(0.78, 0.80, 0.84)
@export var hilt_color: Color = Color(0.18, 0.14, 0.10)
@export var guard_color: Color = Color(0.55, 0.45, 0.20)


func _ready() -> void:
	# Rebuild on load (and in-editor thanks to @tool) so edits to the exports show.
	for c in get_children():
		c.queue_free()
	_build()


func _build() -> void:
	var steel := StandardMaterial3D.new()
	steel.albedo_color = steel_color
	steel.metallic = 0.9
	steel.roughness = 0.25

	var leather := StandardMaterial3D.new()
	leather.albedo_color = hilt_color
	leather.roughness = 0.8

	var brass := StandardMaterial3D.new()
	brass.albedo_color = guard_color
	brass.metallic = 0.8
	brass.roughness = 0.4

	# Grip sits below the origin, guard at origin, blade above — so the hand
	# (at origin) wraps the grip naturally.
	_add_box("Grip", Vector3(0.028, grip_length, 0.028),
		Vector3(0, -grip_length * 0.5, 0), leather)
	_add_box("Pommel", Vector3(0.05, 0.05, 0.05),
		Vector3(0, -grip_length - 0.01, 0), brass)
	_add_box("Guard", Vector3(guard_width, 0.035, 0.05),
		Vector3(0, 0.01, 0), brass)
	_add_box("Blade", Vector3(blade_width, blade_length, blade_thickness),
		Vector3(0, blade_length * 0.5 + 0.03, 0), steel)
	# A thin tip taper: a smaller box near the end reads as a point at this scale.
	_add_box("Tip", Vector3(blade_width * 0.4, 0.12, blade_thickness),
		Vector3(0, blade_length + 0.03, 0), steel)


func _add_box(n: String, size: Vector3, pos: Vector3, mat: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	var mi := MeshInstance3D.new()
	mi.name = n
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)
