extends SceneTree
## One Accord — rebuild the player's AnimationLibrary from imported clips.
##
## Sweeps every imported animation FBX under SEARCH_DIRS, pulls the (already
## canonically-named, by mixamo_anim_post_import.gd) Animation out of each, and
## writes them all into ONE AnimationLibrary saved at OUT_PATH. The player scene
## binds that library to its AnimationPlayer, so re-running this is the only step
## needed after adding/removing clips. No manual drag-and-rename, ever.
##
## Run headless (note: -s, run AFTER a reimport so names are canonical):
##   godot4 --headless --path game-root-oa \
##     -s res://import/build_anim_library.gd
##
## Names come entirely from the post-import hook; this script makes no naming
## decisions — it just collects. If two files resolve to the same canonical name
## the later one wins and a warning is printed (so duplicate mappings are caught).

const SEARCH_DIRS := [
	"res://assets/player/animations",
	"res://assets/player/animations/sword_combat",
]
const OUT_PATH := "res://assets/player/player_anims.res"


func _initialize() -> void:
	var lib := AnimationLibrary.new()
	var seen := {}

	for dir_path: String in SEARCH_DIRS:
		var dir := DirAccess.open(dir_path)
		if dir == null:
			push_warning("build_anim_library: cannot open %s" % dir_path)
			continue
		dir.list_dir_begin()
		var fname := dir.get_next()
		while fname != "":
			if not dir.current_is_dir() and fname.to_lower().ends_with(".fbx"):
				var res_path: String = dir_path.path_join(fname)
				_collect_from(res_path, lib, seen)
			fname = dir.get_next()
		dir.list_dir_end()

	var err := ResourceSaver.save(lib, OUT_PATH)
	if err != OK:
		push_error("build_anim_library: save failed (%d) -> %s" % [err, OUT_PATH])
		quit(1)
		return

	print("build_anim_library: wrote %d clips -> %s" % [seen.size(), OUT_PATH])
	var names := lib.get_animation_list()
	names.sort()
	for n in names:
		print("  - ", n)
	quit(0)


## Load one imported FBX scene, find its AnimationPlayer, copy each animation
## (by its post-import canonical name) into the shared library.
func _collect_from(res_path: String, lib: AnimationLibrary, seen: Dictionary) -> void:
	var packed := ResourceLoader.load(res_path) as PackedScene
	if packed == null:
		push_warning("build_anim_library: not a scene / not imported yet: %s" % res_path)
		return
	var scene := packed.instantiate()
	var ap := _find_anim_player(scene)
	if ap == null:
		scene.free()
		return

	for lib_name in ap.get_animation_library_list():
		var src_lib := ap.get_animation_library(lib_name)
		for anim_name in src_lib.get_animation_list():
			var key := String(anim_name)
			if key == "RESET":
				continue
			var anim: Animation = src_lib.get_animation(anim_name).duplicate()
			_make_in_place(anim)
			if seen.has(key):
				push_warning("build_anim_library: duplicate clip name '%s' (from %s) overwrites earlier" % [key, res_path])
				lib.remove_animation(key)
			lib.add_animation(key, anim)
			seen[key] = res_path

	scene.free()


## Strip baked horizontal travel out of a Mixamo clip ("in place"). Mixamo bakes
## locomotion as Hips-bone translation, so the body drifts during the clip then
## SNAPS BACK when it loops/ends — the "spring/ping". We move via
## CharacterBody3D.velocity, so the clip must never translate the body. We pin
## the Hips X and Z to their first-frame value (cancel horizontal travel) and
## KEEP Y so vertical bob (jumps, crouch dips, breathing) survives. Done here on
## a freshly duplicated, uncompressed Animation so track_set_key_value sticks.
func _make_in_place(anim: Animation) -> void:
	for t in anim.get_track_count():
		if anim.track_get_type(t) != Animation.TYPE_POSITION_3D:
			continue
		if not String(anim.track_get_path(t)).to_lower().contains("hips"):
			continue
		var n := anim.track_get_key_count(t)
		if n == 0:
			continue
		var base: Vector3 = anim.track_get_key_value(t, 0)
		for k in n:
			var v: Vector3 = anim.track_get_key_value(t, k)
			anim.track_set_key_value(t, k, Vector3(base.x, v.y, base.z))


func _find_anim_player(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n
	for c in n.get_children():
		var f := _find_anim_player(c)
		if f:
			return f
	return null
