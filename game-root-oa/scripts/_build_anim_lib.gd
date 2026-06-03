@tool
extends SceneTree
## Build a shared AnimationLibrary from the Mixamo animation FBX files.
##
## Each Mixamo anim FBX imports as a scene whose AnimationPlayer holds one clip
## named "mixamo_com". We pull that clip out of each, give it a friendly name,
## set the right loop mode, and pack them all into ONE AnimationLibrary saved at
## res://assets/player/player_anims.res. The player scene loads this library into
## its AnimationPlayer so an AnimationTree can blend the clips.
##
## Run headless (re-run any time you add/replace animations):
##   godot4 --headless --path . --script res://scripts/_build_anim_lib.gd

const OUT := "res://assets/player/player_anims.res"

# clip_name -> { file, loop }
const CLIPS := {
	"idle":      {"file": "res://assets/player/animations/Breathing_Idle.fbx", "loop": true},
	"walk":      {"file": "res://assets/player/animations/Standard_Walk.fbx",  "loop": true},
	"run":       {"file": "res://assets/player/animations/Running.fbx",         "loop": true},
	"jump":      {"file": "res://assets/player/animations/Jump.fbx",            "loop": false},
	"run_jump":  {"file": "res://assets/player/animations/Running_Jump.fbx",    "loop": false},
	"start_walk":{"file": "res://assets/player/animations/Start_Walking.fbx",   "loop": false},
}

func _find_ap(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for c in node.get_children():
		var r := _find_ap(c)
		if r:
			return r
	return null

func _init() -> void:
	var lib := AnimationLibrary.new()
	for clip_name in CLIPS:
		var info: Dictionary = CLIPS[clip_name]
		var ps := load(info["file"]) as PackedScene
		if ps == null:
			push_error("missing " + info["file"]); continue
		var inst := ps.instantiate()
		var ap := _find_ap(inst)
		var src := ap.get_animation("mixamo_com")
		# Duplicate so we own a standalone copy (the source is owned by the import).
		var anim := src.duplicate(true) as Animation
		anim.loop_mode = Animation.LOOP_LINEAR if info["loop"] else Animation.LOOP_NONE
		lib.add_animation(clip_name, anim)
		inst.free()
		print("added clip '%s' (%.2fs, loop=%s)" % [clip_name, anim.length, info["loop"]])

	var err := ResourceSaver.save(lib, OUT)
	if err == OK:
		print("saved AnimationLibrary -> ", OUT, " (", lib.get_animation_list().size(), " clips)")
	else:
		push_error("save failed: %d" % err)
	quit()
