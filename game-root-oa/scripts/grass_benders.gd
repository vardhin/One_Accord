extends Node
## One Accord — feeds bender positions to the interactive grass shader.
##
## The grass mesh shader (grass_interactive.gdshader) bends blades away from up to
## 8 "benders" (the player now; NPCs/creatures later). This script packs each
## bender's world position + influence radius into the shader's `grass_benders`
## uniform array every frame. Because all the Terrain3DParticles grid nodes share
## one mesh material, setting it once here updates the whole field.
##
## Add benders by dropping their nodes into the `benders` array in the Inspector.
## A bender just needs to be a Node3D (we read global_position); no special API.

const MAX_BENDERS := 8

## Every grass material that should react (ambient carpet + tall cuttable grass).
## All of them share the same `grass_benders`/`grass_bender_count` uniforms.
@export var grass_materials: Array[ShaderMaterial] = []
## Nodes (Node3D) that flatten grass around them — player first, NPCs later.
## Exported as resolved nodes (the scene stores them via node_paths).
@export var benders: Array[Node3D] = []
## Influence radius in metres; blades within this of a bender bend away.
@export var bend_radius: float = 1.6

var _packed := PackedVector4Array()


func _ready() -> void:
	_packed.resize(MAX_BENDERS)
	if grass_materials.is_empty():
		push_warning("grass_benders: no grass_materials assigned; grass won't react.")
		set_physics_process(false)


## Register an extra bender at runtime (e.g. a spawned NPC).
func add_bender(node: Node3D) -> void:
	if node and not benders.has(node):
		benders.append(node)


func _physics_process(_delta: float) -> void:
	if grass_materials.is_empty():
		return
	var count := 0
	for i in MAX_BENDERS:
		if i < benders.size() and is_instance_valid(benders[i]):
			var pos := benders[i].global_position
			_packed[i] = Vector4(pos.x, pos.y, pos.z, bend_radius)
			count += 1
		else:
			_packed[i] = Vector4(0.0, 0.0, 0.0, 0.0)  # radius 0 = ignored by shader
	for mat in grass_materials:
		if mat:
			mat.set_shader_parameter("grass_benders", _packed)
			mat.set_shader_parameter("grass_bender_count", count)
