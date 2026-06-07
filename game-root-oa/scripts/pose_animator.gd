extends Node3D
## One Accord — in-game pose-to-pose animation authoring tool.
##
## A fully RUNTIME tool: enter pose mode while the game is playing, drag a limb
## (hand / foot / head) with the mouse, freeze the pose as a keyframe, repeat for
## any number of poses, preview the smooth interpolated result, and SAVE it as a
## portable Godot `Animation` (.tres) you can drop on any same-skeleton
## `AnimationPlayer`.
##
## WHY IT WORKS AT RUNTIME: bones aren't natively clickable, so each draggable
## effector gets a small floating `Area3D` "handle" you pick with the mouse. The
## limb is solved with a tiny analytic 2-bone IK (law of cosines) — no deprecated
## SkeletonIK3D, works on gl_compatibility. Freezing snapshots every bone's LOCAL
## rotation, so saved clips are bone-relative and portable.
##
## Drop this node anywhere under (or beside) the Player; it finds the Skeleton3D
## by walking the tree. It drives the player's existing AnimationPlayer for
## preview. While pose mode is active it sets `player.pose_mode_active = true` so
## the controller stops eating input / moving the body.
##
## ── HANDLES ───────────────────────────────────────────────────────────────
## Big BLUE handles are IK tips (hands, feet): drag them in space and a 2-bone
## IK solves the limb. Small GREEN handles are direct-rotate joints (wrists,
## elbows, knees, shoulders, spine, neck, head, hips): they stay glued to the
## body and are posed only through the inspector sliders, so they can never be
## pulled off the skeleton.
##
## CAMERA: the mouse is freed in pose mode so you can click handles/UI. Hold the
## RIGHT mouse button and drag to orbit the camera (left-click picks handles).
##
## ── CONTROLS ──────────────────────────────────────────────────────────────
##   K            toggle pose mode (frees the mouse, freezes the player)
##   Click handle select a joint (or Tab to cycle); it highlights gold
##   LMB drag     move an IK/aim handle (hand/foot/head); IK solves
##   Wheel        push/pull the active IK/aim handle toward/away (depth)
##   Sliders      RIGHT panel edits the selected bone's LOCAL transform —
##                Position / Rotation (deg) / Scale, X/Y/Z, Godot-Inspector style
##   F            add the current pose as a CHECKPOINT (point 1, 2, 3, …)
##   LEFT panel   the checkpoint timeline: click # to view a checkpoint, edit the
##                per-segment SECONDS box to set speed into it, ▲ re-record, ✕
##                delete. A mini bar visualises spacing + the preview playhead.
##   Enter        build + preview the interpolated clip (uses your per-seg speeds)
##   Ctrl+S       save the animation to res://resources/poses/<name>.tres
##   Esc          leave pose mode

# --- Tunables -------------------------------------------------------------
@export var save_dir: String = "res://resources/poses"
## Pre-filled into the save dialog; updated to whatever you last saved.
@export var clip_name: String = "spell_cast"
## Seconds between consecutive frozen keyframes in the baked animation.
@export var frame_spacing: float = 0.5
## Handle pick/visual radius (metres).
@export var handle_radius: float = 0.06
## Mouse-wheel depth step (metres) when pushing a handle along the view ray.
@export var depth_step: float = 0.1
@export var active_color: Color = Color(1.0, 0.85, 0.1)
@export var idle_color: Color = Color(0.2, 0.7, 1.0)

# Physical keycodes (so we need no project.godot input actions).
const KEY_K := 75
const KEY_F := 70
const KEY_TAB := 4194306
const KEY_ENTER := 4194309
const KEY_BACKSPACE := 4194308
const KEY_ESC := 4194305
const KEY_S := 83
const KEY_CTRL := 4194326

# --- Effector / chain table ----------------------------------------------
# Each effector is the TIP of a 2-bone IK chain: [root_bone, mid_bone, tip_bone].
# `pole` biases which way the joint (elbow/knee) bends in the chain's local-ish
# frame; tweak per-rig if a knee inverts. Names use Mixamo's underscore form,
# with colon/plain fallbacks resolved at bind time.
const CHAINS := {
	"R Hand": {"bones": ["mixamorig_RightArm", "mixamorig_RightForeArm", "mixamorig_RightHand"], "pole": Vector3(0, 0, -1)},
	"L Hand": {"bones": ["mixamorig_LeftArm", "mixamorig_LeftForeArm", "mixamorig_LeftHand"], "pole": Vector3(0, 0, -1)},
	"R Foot": {"bones": ["mixamorig_RightUpLeg", "mixamorig_RightLeg", "mixamorig_RightFoot"], "pole": Vector3(0, 0, 1)},
	"L Foot": {"bones": ["mixamorig_LeftUpLeg", "mixamorig_LeftLeg", "mixamorig_LeftFoot"], "pole": Vector3(0, 0, 1)},
}
# Single-bone "look"/aim effectors: just point the bone at the handle. (None by
# default — the head used to live here, but auto-aiming snapped it to the seed
# direction on entry; it is now a plain rotate joint below instead.)
const AIMS := {}
# Single-bone DIRECT-ROTATE effectors. Their handle sits ON the bone and never
# drives IK — you rotate the bone purely through the inspector sliders, so the
# joint can never be dragged away from the body (the handle just follows it).
# These cover the in-between joints the IK tips don't: wrists, elbows, knees,
# shoulders, spine, neck.
const JOINTS := {
	"R Shoulder": {"bone": "mixamorig_RightShoulder"},
	"L Shoulder": {"bone": "mixamorig_LeftShoulder"},
	"R Elbow":    {"bone": "mixamorig_RightForeArm"},
	"L Elbow":    {"bone": "mixamorig_LeftForeArm"},
	"R Wrist":    {"bone": "mixamorig_RightHand"},
	"L Wrist":    {"bone": "mixamorig_LeftHand"},
	"R Knee":     {"bone": "mixamorig_RightLeg"},
	"L Knee":     {"bone": "mixamorig_LeftLeg"},
	"Hips":       {"bone": "mixamorig_Hips"},
	"Spine":      {"bone": "mixamorig_Spine1"},
	"Chest":      {"bone": "mixamorig_Spine2"},
	"Neck":       {"bone": "mixamorig_Neck"},
	"Head":       {"bone": "mixamorig_Head"},
}

# --- Runtime state --------------------------------------------------------
var _skel: Skeleton3D
var _anim_player: AnimationPlayer
var _player: Node                       ## the CharacterBody3D controller (optional)
var _camera: Camera3D

var _active: bool = false               ## pose mode on/off
var _effectors: Array = []              ## [{name, kind, bones:[idx], pole, handle:Area3D, target:Vector3}]
var _active_idx: int = 0
var _dragging: bool = false
var _drag_depth: float = 0.0            ## distance from camera to the drag plane

var _poses: Array = []                  ## Array of {bone_idx -> Quaternion}, plus "_root_pos"
## Seconds to travel INTO each checkpoint from the previous one. Parallel to
## `_poses`; index 0 is the start (its value is ignored). Lower = faster segment.
var _durations: Array = []              ## Array[float]
var _selected_pose: int = -1            ## checkpoint highlighted in the timeline (-1 = none)
var _previewing: bool = false
var _bake_lib_added: bool = false
var _hud_label: Label

# --- Inspector (transform editor) ----------------------------------------
## Bones whose transform was set BY HAND in the inspector. IK skips these so a
## manual edit isn't immediately overwritten by the solver each frame. Grabbing
## a handle (or pressing Tab to a fresh effector) re-enables IK for that bone.
var _manual_bones: Dictionary = {}      ## bone_idx -> true
var _ui_layer: CanvasLayer
var _inspector: VBoxContainer
var _inspector_title: Label
## Per-axis drag sliders, grouped: {"pos":[3 HSlider], "rot":[...], "scale":[...]}.
var _sliders: Dictionary = {}
var _syncing_ui: bool = false           ## guard so refreshing sliders doesn't re-edit the bone
const ROT_RANGE := 180.0                ## degrees, slider min/max per rotation axis
const POS_RANGE := 0.5                  ## metres, slider min/max per position axis (local)
const SCALE_MIN := 0.2
const SCALE_MAX := 3.0

# --- Timeline (checkpoint editor) ----------------------------------------
## The left-hand panel: a mini visual bar of checkpoints over the clip's time,
## plus a numbered, editable list (select / jump / retime / delete each one).
var _timeline_panel: PanelContainer
var _timeline_bar: Control               ## custom-drawn mini timeline (markers + playhead)
var _timeline_rows: VBoxContainer        ## the per-checkpoint row list
var _timeline_summary: Label
const SEG_MIN := 0.05                     ## fastest allowed segment (s)
const SEG_MAX := 5.0                      ## slowest allowed segment (s)


func _ready() -> void:
	# Resolve the skeleton + animation player by walking up to a common ancestor
	# (the Player) and back down. Robust to where this node is parented.
	var search_root: Node = get_parent()
	# Climb a couple levels so we can see siblings like Body/X_Bot/...
	for _i in 3:
		if search_root and search_root.get_parent():
			search_root = search_root.get_parent()
	_skel = _find_skeleton(search_root if search_root else get_tree().current_scene)
	if _skel == null:
		push_error("PoseAnimator: no Skeleton3D found in the scene tree.")
		set_process(false)
		set_process_unhandled_input(false)
		return
	_anim_player = _find_anim_player(_skel)
	_player = _find_player(_skel)
	set_process_unhandled_input(true)
	# Build the (initially hidden) handles up front.
	_build_effectors()
	_hide_handles()


# ── Lookups ───────────────────────────────────────────────────────────────
func _find_skeleton(n: Node) -> Skeleton3D:
	if n == null:
		return null
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var f := _find_skeleton(c)
		if f:
			return f
	return null


func _find_anim_player(skel: Node) -> AnimationPlayer:
	# Mixamo import puts the AnimationPlayer as a sibling of the Skeleton3D.
	var p := skel.get_parent()
	if p:
		for c in p.get_children():
			if c is AnimationPlayer:
				return c
	# Fallback: search the whole scene.
	return _walk_for_type(get_tree().current_scene, "AnimationPlayer") as AnimationPlayer


func _find_player(skel: Node) -> Node:
	var n: Node = skel
	while n:
		if n is CharacterBody3D:
			return n
		n = n.get_parent()
	return null


func _walk_for_type(n: Node, type_name: String) -> Node:
	if n == null:
		return null
	if n.is_class(type_name):
		return n
	for c in n.get_children():
		var f := _walk_for_type(c, type_name)
		if f:
			return f
	return null


func _resolve_bone(base: String) -> int:
	# Try the table name, then common Mixamo naming variants.
	var idx := _skel.find_bone(base)
	if idx != -1:
		return idx
	var variants := [
		base.replace("mixamorig_", "mixamorig:"),
		base.replace("mixamorig_", ""),
	]
	for v in variants:
		idx = _skel.find_bone(v)
		if idx != -1:
			return idx
	return -1


# ── Effector handles ──────────────────────────────────────────────────────
func _build_effectors() -> void:
	for name in CHAINS:
		var data: Dictionary = CHAINS[name]
		var idxs: Array = []
		var ok := true
		for b in data["bones"]:
			var bi := _resolve_bone(b)
			if bi == -1:
				ok = false
				break
			idxs.append(bi)
		if not ok:
			push_warning("PoseAnimator: chain '%s' missing bones; skipped." % name)
			continue
		_effectors.append({
			"name": name, "kind": "ik", "bones": idxs,
			"pole": data["pole"], "handle": _make_handle(name), "target": Vector3.ZERO,
		})
	for name in AIMS:
		var bi := _resolve_bone(AIMS[name]["bone"])
		if bi == -1:
			push_warning("PoseAnimator: aim '%s' bone missing; skipped." % name)
			continue
		_effectors.append({
			"name": name, "kind": "aim", "bones": [bi],
			"pole": Vector3.UP, "handle": _make_handle(name), "target": Vector3.ZERO,
		})
	for name in JOINTS:
		var bi := _resolve_bone(JOINTS[name]["bone"])
		if bi == -1:
			push_warning("PoseAnimator: joint '%s' bone missing; skipped." % name)
			continue
		# Smaller, greenish handles so the many joint markers read distinctly from
		# the larger blue IK tips (hand/foot) and don't crowd them.
		_effectors.append({
			"name": name, "kind": "rotate", "bones": [bi],
			"pole": Vector3.UP, "target": Vector3.ZERO,
			"handle": _make_handle(name, handle_radius * 0.7, Color(0.4, 0.95, 0.5)),
		})


func _make_handle(label: String, radius: float = -1.0, base_col: Color = Color.TRANSPARENT) -> Area3D:
	var r := handle_radius if radius < 0.0 else radius
	var c := idle_color if base_col.a == 0.0 else base_col
	var area := Area3D.new()
	area.name = "Handle_" + label
	area.input_ray_pickable = true
	var col := CollisionShape3D.new()
	var sph := SphereShape3D.new()
	sph.radius = r
	col.shape = sph
	area.add_child(col)
	# Visible marker.
	var mesh := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = r
	sm.height = r * 2.0
	mesh.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = c
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test = true               # always visible, even behind the body
	mat.render_priority = 10
	mesh.material_override = mat
	area.add_child(mesh)
	add_child(area)
	area.set_meta("mesh", mesh)
	area.set_meta("mat", mat)
	area.set_meta("base_col", c)           # remembered so colors restore after de-select
	return area


func _hide_handles() -> void:
	for e in _effectors:
		e["handle"].visible = false


## The bone the inspector edits for the active effector: the chain TIP for IK
## effectors, or the single bone for aim effectors.
func _inspect_bone() -> int:
	if _effectors.is_empty():
		return -1
	var e: Dictionary = _effectors[_active_idx]
	return e["bones"][e["bones"].size() - 1]


# ── Pose-mode toggling ────────────────────────────────────────────────────
func _set_pose_mode(on: bool) -> void:
	_active = on
	if _player and "pose_mode_active" in _player:
		_player.pose_mode_active = on
	if on:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_camera = get_viewport().get_camera_3d()
		_previewing = false
		if _anim_player.is_playing():
			_anim_player.stop()
		# Seed each effector's target at its bone's current world position.
		for e in _effectors:
			var tip: int = e["bones"][e["bones"].size() - 1]
			e["target"] = (_skel.global_transform * _skel.get_bone_global_pose(tip)).origin
			e["handle"].visible = true
		_active_idx = clampi(_active_idx, 0, _effectors.size() - 1)
		_refresh_handle_colors()
		_build_inspector()
		_build_timeline()
		_inspector.visible = true
		_timeline_panel.visible = true
		_refresh_inspector_values()
		_rebuild_timeline()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_dragging = false
		_hide_handles()
		if _inspector:
			_inspector.visible = false
		if _timeline_panel:
			_timeline_panel.visible = false
	_show_hud()


func _refresh_handle_colors() -> void:
	for i in _effectors.size():
		var handle: Area3D = _effectors[i]["handle"]
		var mat: StandardMaterial3D = handle.get_meta("mat")
		mat.albedo_color = active_color if i == _active_idx else handle.get_meta("base_col")


# ── Input ─────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var kc: int = event.physical_keycode
		if kc == KEY_K:
			_set_pose_mode(not _active)
			get_viewport().set_input_as_handled()
			return
		if not _active:
			return
		match kc:
			KEY_TAB:
				_active_idx = (_active_idx + 1) % _effectors.size()
				_refresh_handle_colors()
				_show_hud()
				_refresh_inspector_values()
			KEY_F:
				_freeze_pose()
			KEY_BACKSPACE:
				# Delete the selected checkpoint (or the last one if none selected).
				_delete_pose(_selected_pose if _selected_pose != -1 else _poses.size() - 1)
			KEY_ENTER:
				_preview()
			KEY_ESC:
				_set_pose_mode(false)
			KEY_S:
				if Input.is_key_pressed(KEY_CTRL):
					_save()
		get_viewport().set_input_as_handled()
		return

	if not _active:
		return

	# Mouse-wheel: push/pull the active handle along the camera ray.
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_nudge_depth(-depth_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_nudge_depth(depth_step)

	# Begin / end a drag with the left button.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_pick(event.position)
		else:
			_dragging = false

	if event is InputEventMouseMotion and _dragging:
		_drag_to(event.position)


func _try_pick(screen_pos: Vector2) -> void:
	if _camera == null:
		_camera = get_viewport().get_camera_3d()
	var from := _camera.project_ray_origin(screen_pos)
	var dir := _camera.project_ray_normal(screen_pos)
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, from + dir * 100.0)
	q.collide_with_areas = true
	q.collide_with_bodies = false
	var hit := space.intersect_ray(q)
	if hit and hit.has("collider"):
		for i in _effectors.size():
			if _effectors[i]["handle"] == hit["collider"]:
				_active_idx = i
				_refresh_handle_colors()
				# "rotate" joints are slider-only: selecting them must NOT start a
				# spatial drag (that's what keeps them glued to the body). IK tips
				# (hand/foot) and aim (head) can be dragged in space.
				if _effectors[i]["kind"] == "rotate":
					_dragging = false
				else:
					_dragging = true
					# Grabbing a handle resumes IK control of this chain's tip: drop
					# any manual pin and re-seed the target at the bone's position.
					var tip: int = _effectors[i]["bones"][_effectors[i]["bones"].size() - 1]
					_manual_bones.erase(tip)
					_effectors[i]["target"] = (_skel.global_transform * _skel.get_bone_global_pose(tip)).origin
					# Lock the drag plane at the handle's current depth from camera.
					_drag_depth = (_effectors[i]["target"] - from).dot(dir)
				_show_hud()
				_refresh_inspector_values()
				return


func _drag_to(screen_pos: Vector2) -> void:
	var from := _camera.project_ray_origin(screen_pos)
	var dir := _camera.project_ray_normal(screen_pos)
	var target := from + dir * _drag_depth
	_effectors[_active_idx]["target"] = target


func _nudge_depth(amount: float) -> void:
	# Move the active handle toward/away from the camera along its view ray.
	if _camera == null:
		return
	var e: Dictionary = _effectors[_active_idx]
	var to_cam: Vector3 = (e["target"] - _camera.global_position)
	var n: Vector3 = to_cam.normalized()
	e["target"] += n * amount
	_drag_depth += amount


# ── IK solve (runs every frame so handles drive the pose live) ────────────
func _process(_delta: float) -> void:
	if not _active:
		return
	# While previewing, the AnimationPlayer owns the skeleton — just animate the
	# playhead on the mini timeline and skip handle/IK/inspector work.
	if _previewing:
		if _timeline_bar:
			_timeline_bar.queue_redraw()
		if not _anim_player.is_playing():
			_previewing = false
		return
	for e in _effectors:
		var tip: int = e["bones"][e["bones"].size() - 1]
		# "rotate" joints are ALWAYS glued to their bone (slider-driven only), so
		# they track the body and can never be pulled off it.
		if e["kind"] == "rotate" or _manual_bones.has(tip):
			# A bone edited by hand in the inspector is likewise "pinned": skip IK so
			# the manual transform survives; keep the handle on the bone.
			e["handle"].global_position = (_skel.global_transform * _skel.get_bone_global_pose(tip)).origin
			continue
		# Keep the visible handle glued to its target.
		e["handle"].global_position = e["target"]
		if e["kind"] == "ik":
			_solve_two_bone(e)
		elif e["kind"] == "aim":
			_solve_aim(e)
	# Keep the inspector sliders showing the active bone's live values — but only
	# for IK-driven bones (a pinned/manual bone's values come from the sliders
	# themselves, so re-writing them would fight an in-progress drag).
	if _inspector and _inspector.visible and not _manual_bones.has(_inspect_bone()):
		_refresh_inspector_values()


## Analytic two-bone IK. Rotates the root and mid bones so the chain tip reaches
## (or stretches toward) the world-space target. Operates in the skeleton's local
## space via bone global poses, then writes back local poses.
func _solve_two_bone(e: Dictionary) -> void:
	var b_root: int = e["bones"][0]
	var b_mid: int = e["bones"][1]
	var b_tip: int = e["bones"][2]
	var sk_inv := _skel.global_transform.affine_inverse()

	# Positions in skeleton-local space.
	var root_pos := _skel.get_bone_global_pose(b_root).origin
	var mid_pos := _skel.get_bone_global_pose(b_mid).origin
	var tip_pos := _skel.get_bone_global_pose(b_tip).origin
	var goal: Vector3 = (sk_inv * e["target"])

	var upper := (mid_pos - root_pos).length()
	var lower := (tip_pos - mid_pos).length()
	if upper < 1e-5 or lower < 1e-5:
		return

	var to_goal := goal - root_pos
	var dist := clampf(to_goal.length(), 0.001, upper + lower - 0.001)
	var dir := to_goal.normalized()

	# Law of cosines: angle at the root between the upper bone and the goal dir.
	var cos_root := clampf((upper * upper + dist * dist - lower * lower) / (2.0 * upper * dist), -1.0, 1.0)
	var root_angle := acos(cos_root)

	# Build a bend plane from the goal direction and the pole hint.
	var pole: Vector3 = e["pole"].normalized()
	var axis := dir.cross(pole)
	if axis.length() < 1e-4:
		axis = dir.cross(Vector3.RIGHT)
		if axis.length() < 1e-4:
			axis = dir.cross(Vector3.UP)
	axis = axis.normalized()

	# Desired world-ish (skeleton-local) directions for the two bones.
	var upper_dir := dir.rotated(axis, root_angle)
	var elbow_pos := root_pos + upper_dir * upper

	# --- Orient ROOT bone so its current tip-direction maps onto upper_dir. ---
	var cur_upper := (mid_pos - root_pos).normalized()
	var rot_root := _rotation_between(cur_upper, upper_dir)
	_apply_delta_rotation(b_root, rot_root)

	# Recompute mid after root moved, then orient MID toward the goal.
	mid_pos = _skel.get_bone_global_pose(b_mid).origin
	tip_pos = _skel.get_bone_global_pose(b_tip).origin
	var cur_lower := (tip_pos - mid_pos).normalized()
	var want_lower := (goal - mid_pos).normalized()
	# Clamp the reach so the lower bone aims at the real elbow→goal line.
	want_lower = (goal - elbow_pos).normalized()
	var rot_mid := _rotation_between(cur_lower, want_lower)
	_apply_delta_rotation(b_mid, rot_mid)


## Single-bone aim: point the bone's local +Y (Mixamo bone "up") at the target.
func _solve_aim(e: Dictionary) -> void:
	var b: int = e["bones"][0]
	var sk_inv := _skel.global_transform.affine_inverse()
	var bone_pos := _skel.get_bone_global_pose(b).origin
	var goal: Vector3 = sk_inv * e["target"]
	var cur := _skel.get_bone_global_pose(b)
	var cur_dir := (cur.basis.y).normalized()         # bone's current up
	var want := (goal - bone_pos).normalized()
	if want.length() < 1e-4:
		return
	var delta := _rotation_between(cur_dir, want)
	_apply_delta_rotation(b, delta)


## Rotate bone `b` in skeleton-local space by `delta` (a Basis), writing back its
## LOCAL pose so parent transforms stay intact.
func _apply_delta_rotation(b: int, delta: Basis) -> void:
	var gp := _skel.get_bone_global_pose(b)
	var new_global := Transform3D(delta * gp.basis, gp.origin)
	var parent := _skel.get_bone_parent(b)
	var parent_global := _skel.get_bone_global_pose(parent) if parent != -1 else Transform3D.IDENTITY
	var new_local := parent_global.affine_inverse() * new_global
	_skel.set_bone_pose_rotation(b, new_local.basis.get_rotation_quaternion())


func _rotation_between(a: Vector3, b: Vector3) -> Basis:
	a = a.normalized()
	b = b.normalized()
	var d := clampf(a.dot(b), -1.0, 1.0)
	if d > 0.99999:
		return Basis()
	if d < -0.99999:
		# Opposite: rotate 180° about any perpendicular axis.
		var perp := a.cross(Vector3.UP)
		if perp.length() < 1e-4:
			perp = a.cross(Vector3.RIGHT)
		return Basis(perp.normalized(), PI)
	var axis := a.cross(b).normalized()
	var angle := acos(d)
	return Basis(axis, angle)


# ── Keyframing ────────────────────────────────────────────────────────────
func _freeze_pose() -> void:
	# Snapshot every bone's LOCAL rotation quaternion (portable, bone-relative),
	# plus the hips world-ish position so a moving root is captured too.
	var pose := {}
	for b in _skel.get_bone_count():
		pose[b] = _skel.get_bone_pose_rotation(b)
	# Root translation (hips) so position tracks can be baked if needed.
	var hips := _resolve_bone("mixamorig_Hips")
	if hips != -1:
		pose["_root_pos"] = _skel.get_bone_pose_position(hips)
		pose["_root_bone"] = hips
	_poses.append(pose)
	# First checkpoint has no incoming segment; later ones default to frame_spacing.
	_durations.append(0.0 if _poses.size() == 1 else frame_spacing)
	_selected_pose = _poses.size() - 1
	_show_hud()
	_rebuild_timeline()


## Absolute time of checkpoint `i` = sum of all segment durations up to it.
func _pose_time(i: int) -> float:
	var t := 0.0
	for k in range(1, i + 1):
		t += maxf(0.01, float(_durations[k]))
	return t


## Total clip length = time of the last checkpoint.
func _total_time() -> float:
	return _pose_time(_poses.size() - 1) if _poses.size() > 0 else 0.0


# ── Bake → Animation ──────────────────────────────────────────────────────
func _build_animation() -> Animation:
	var anim := Animation.new()
	if _poses.is_empty():
		return anim
	# Per-checkpoint timing: each key sits at its cumulative time, so per-segment
	# speed (the timeline's duration fields) is baked straight into the clip.
	anim.length = maxf(0.001, _total_time())
	anim.loop_mode = Animation.LOOP_NONE

	# One rotation-3D track per bone that actually moves across the poses.
	# Track path format: "<skeleton_node>:<bone_name>"
	for b in _skel.get_bone_count():
		var track := anim.add_track(Animation.TYPE_ROTATION_3D)
		var bone_name := _skel.get_bone_name(b)
		anim.track_set_path(track, NodePath(_skeleton_track_base() + ":" + bone_name))
		anim.track_set_interpolation_type(track, Animation.INTERPOLATION_CUBIC)
		for i in _poses.size():
			anim.rotation_track_insert_key(track, _pose_time(i), _poses[i][b])

	# Root position track (hips) if we captured one.
	if _poses[0].has("_root_bone"):
		var hips: int = _poses[0]["_root_bone"]
		var ptrack := anim.add_track(Animation.TYPE_POSITION_3D)
		anim.track_set_path(ptrack, NodePath(_skeleton_track_base() + ":" + _skel.get_bone_name(hips)))
		anim.track_set_interpolation_type(ptrack, Animation.INTERPOLATION_CUBIC)
		for i in _poses.size():
			if _poses[i].has("_root_pos"):
				anim.position_track_insert_key(ptrack, _pose_time(i), _poses[i]["_root_pos"])
	return anim


## The node path the AnimationPlayer uses to reach the skeleton, relative to its
## root_node. Bone tracks are "<that path>:<bone_name>".
func _skeleton_track_base() -> String:
	var root := _anim_player.get_node_or_null(_anim_player.root_node)
	if root == null:
		root = _anim_player.get_parent()
	return str(root.get_path_to(_skel))


func _preview() -> void:
	if _poses.size() < 2:
		_flash_hud("Add at least 2 checkpoints to preview an animation.")
		return
	var anim := _build_animation()
	var lib := _anim_player.get_animation_library("")
	if lib == null:
		lib = AnimationLibrary.new()
		_anim_player.add_animation_library("", lib)
	if lib.has_animation("__pose_preview"):
		lib.remove_animation("__pose_preview")
	lib.add_animation("__pose_preview", anim)
	_previewing = true
	_anim_player.play("__pose_preview")
	_flash_hud("Previewing %d checkpoints (%.2fs)…" % [_poses.size(), anim.length])


## Ctrl+S: ask for a clip name (pre-filled with the last one), then save.
func _save() -> void:
	if _poses.is_empty():
		_flash_hud("Nothing to save — add a checkpoint first.")
		return
	_prompt_save_name()


## Pop up a small dialog asking what to call the clip. Confirming writes
## <save_dir>/<name>.tres (overwriting if it already exists, which is fine for
## re-recording the same clip).
func _prompt_save_name() -> void:
	_ensure_ui_layer()
	var dlg := AcceptDialog.new()
	dlg.title = "Save animation"
	dlg.dialog_hide_on_ok = true
	dlg.ok_button_text = "Save"
	dlg.add_cancel_button("Cancel")

	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(320, 0)
	var lbl := Label.new()
	lbl.text = "Clip name (saved to %s/<name>.tres):" % save_dir
	box.add_child(lbl)
	var edit := LineEdit.new()
	edit.text = clip_name
	edit.placeholder_text = "e.g. spell_cast"
	edit.select_all()
	box.add_child(edit)
	dlg.add_child(box)

	_ui_layer.add_child(dlg)
	# Confirm on the button OR on Enter in the field; tidy up the dialog after.
	dlg.confirmed.connect(func() -> void: _do_save(edit.text))
	edit.text_submitted.connect(func(_t: String) -> void: dlg.get_ok_button().emit_signal("pressed"))
	dlg.close_requested.connect(dlg.queue_free)
	dlg.confirmed.connect(dlg.queue_free)
	dlg.canceled.connect(dlg.queue_free)
	dlg.popup_centered()
	edit.grab_focus()


func _do_save(name: String) -> void:
	# Sanitise to a safe, predictable filename.
	var clean := name.strip_edges()
	if clean == "":
		_flash_hud("Save cancelled — empty name.")
		return
	clean = clean.to_lower().replace(" ", "_").validate_filename()
	clip_name = clean   # remember for the next prompt

	var anim := _build_animation()
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_recursive_absolute(save_dir)
	var path := "%s/%s.tres" % [save_dir, clean]
	var err := ResourceSaver.save(anim, path)
	if err == OK:
		_flash_hud("Saved → %s" % path)
		print("PoseAnimator: saved animation to ", path)
	else:
		_flash_hud("Save FAILED (err %d)" % err)
		push_error("PoseAnimator: save failed, err %d" % err)


# ── On-screen HUD (auto-created label) ────────────────────────────────────
func _ensure_ui_layer() -> void:
	if _ui_layer == null:
		_ui_layer = CanvasLayer.new()
		_ui_layer.layer = 100
		add_child(_ui_layer)


func _show_hud() -> void:
	if _hud_label == null:
		_ensure_ui_layer()
		_hud_label = Label.new()
		_hud_label.add_theme_color_override("font_color", Color.WHITE)
		_hud_label.add_theme_color_override("font_outline_color", Color.BLACK)
		_hud_label.add_theme_constant_override("outline_size", 6)
		_hud_label.position = Vector2(16, 16)
		_ui_layer.add_child(_hud_label)
	_hud_label.visible = _active
	if not _active:
		return
	var active_name: String = _effectors[_active_idx]["name"] if _effectors.size() > 0 else "—"
	_hud_label.text = "POSE MODE  ·  active: %s  ·  checkpoints: %d\nClick handle to select · LMB drag hand/foot · RMB drag = orbit camera · Wheel depth\nRight panel: pos / rot / scale sliders   Left panel: checkpoints + speed\n[F] add checkpoint  [Enter] preview  [Ctrl+S] save  [Esc] exit" % [active_name, _poses.size()]


func _flash_hud(msg: String) -> void:
	_show_hud()
	if _hud_label:
		_hud_label.text = msg + "\n\n" + _hud_label.text


# ── Inspector: per-axis transform editor (Godot-Inspector-style) ──────────
## A panel on the right with drag-sliders for the active bone's LOCAL transform:
## Position X/Y/Z (m), Rotation X/Y/Z (deg), Scale X/Y/Z. Dragging a slider pins
## the bone (IK stops fighting it); grab a handle again to hand control back.
func _build_inspector() -> void:
	if _inspector != null:
		return
	_ensure_ui_layer()

	# Right-anchored dark panel.
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -252.0
	panel.offset_right = -12.0
	panel.offset_top = 12.0
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.55)
	sb.set_content_margin_all(10.0)
	sb.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", sb)
	_ui_layer.add_child(panel)

	_inspector = VBoxContainer.new()
	_inspector.add_theme_constant_override("separation", 4)
	_inspector.custom_minimum_size = Vector2(228, 0)
	panel.add_child(_inspector)

	_inspector_title = Label.new()
	_inspector_title.add_theme_color_override("font_color", active_color)
	_inspector.add_child(_inspector_title)

	_sliders = {
		"pos": _add_axis_group("Position (m)", "pos", -POS_RANGE, POS_RANGE, 0.001),
		"rot": _add_axis_group("Rotation (°)", "rot", -ROT_RANGE, ROT_RANGE, 0.5),
		"scale": _add_axis_group("Scale", "scale", SCALE_MIN, SCALE_MAX, 0.01),
	}


## Build one labelled section of three X/Y/Z sliders. Returns the three HSliders.
func _add_axis_group(title: String, key: String, lo: float, hi: float, step: float) -> Array:
	var head := Label.new()
	head.text = title
	head.add_theme_color_override("font_color", Color(0.8, 0.92, 1.0))
	_inspector.add_child(head)

	var axes := ["X", "Y", "Z"]
	var out: Array = []
	for ax in 3:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var name_lbl := Label.new()
		name_lbl.text = axes[ax]
		name_lbl.custom_minimum_size = Vector2(14, 0)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		row.add_child(name_lbl)

		var slider := HSlider.new()
		slider.min_value = lo
		slider.max_value = hi
		slider.step = step
		slider.custom_minimum_size = Vector2(150, 0)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Bind which axis/group this slider drives so one handler updates the bone.
		slider.value_changed.connect(_on_slider_changed.bind(key, ax))
		row.add_child(slider)

		var val_lbl := Label.new()
		val_lbl.custom_minimum_size = Vector2(48, 0)
		val_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.6))
		row.add_child(val_lbl)
		slider.set_meta("val_lbl", val_lbl)

		_inspector.add_child(row)
		out.append(slider)
	return out


## Push the active bone's current LOCAL transform into the sliders (without
## triggering edits). Called whenever the active bone or its pose changes.
func _refresh_inspector_values() -> void:
	if _inspector == null or _effectors.is_empty():
		return
	var b := _inspect_bone()
	if b == -1:
		return
	_inspector_title.text = "%s  ·  bone: %s" % [_effectors[_active_idx]["name"], _skel.get_bone_name(b)]

	var pos := _skel.get_bone_pose_position(b)
	var rot_deg := _skel.get_bone_pose_rotation(b).get_euler() * (180.0 / PI)
	var scl := _skel.get_bone_pose_scale(b)

	_syncing_ui = true
	_set_group(_sliders["pos"], pos)
	_set_group(_sliders["rot"], rot_deg)
	_set_group(_sliders["scale"], scl)
	_syncing_ui = false


func _set_group(sliders: Array, v: Vector3) -> void:
	for ax in 3:
		var s: HSlider = sliders[ax]
		# Clamp display into the slider's range so out-of-range values don't snap.
		s.value = clampf(v[ax], s.min_value, s.max_value)
		(s.get_meta("val_lbl") as Label).text = "%.3f" % v[ax]


## A slider moved: rebuild the bone's LOCAL transform from all three groups and
## write it back. Pins the bone so per-frame IK leaves it alone.
func _on_slider_changed(_value: float, key: String, axis: int) -> void:
	if _syncing_ui or _effectors.is_empty():
		return
	var b := _inspect_bone()
	if b == -1:
		return

	# Read the live slider values for every group (so editing one axis keeps the
	# others), then compose the local pose.
	var pos := _group_vec(_sliders["pos"])
	var rot_deg := _group_vec(_sliders["rot"])
	var scl := _group_vec(_sliders["scale"])

	_skel.set_bone_pose_position(b, pos)
	_skel.set_bone_pose_rotation(b, Quaternion.from_euler(rot_deg * (PI / 180.0)))
	_skel.set_bone_pose_scale(b, scl)
	_manual_bones[b] = true

	# Update only the edited axis's readout label (cheap; full refresh would fight
	# the drag because set_group writes .value back).
	var s: HSlider = _sliders[key][axis]
	(s.get_meta("val_lbl") as Label).text = "%.3f" % s.value


func _group_vec(sliders: Array) -> Vector3:
	return Vector3(sliders[0].value, sliders[1].value, sliders[2].value)


# ── Checkpoint apply / delete ─────────────────────────────────────────────
## Snap the live skeleton to checkpoint `i` so you can SEE / re-edit that pose.
## Stops any preview and clears manual pins (the checkpoint IS the new truth).
func _jump_to_pose(i: int) -> void:
	if i < 0 or i >= _poses.size():
		return
	if _previewing:
		_anim_player.stop()
		_previewing = false
	var pose: Dictionary = _poses[i]
	for b in _skel.get_bone_count():
		if pose.has(b):
			_skel.set_bone_pose_rotation(b, pose[b])
	if pose.has("_root_bone") and pose.has("_root_pos"):
		_skel.set_bone_pose_position(pose["_root_bone"], pose["_root_pos"])
	_manual_bones.clear()
	_selected_pose = i
	# Re-seed IK targets so handles sit on the restored pose, not the old one.
	for e in _effectors:
		var tip: int = e["bones"][e["bones"].size() - 1]
		e["target"] = (_skel.global_transform * _skel.get_bone_global_pose(tip)).origin
	_refresh_inspector_values()
	_rebuild_timeline()


## Overwrite checkpoint `i` with the skeleton's CURRENT pose (re-record in place).
func _replace_pose(i: int) -> void:
	if i < 0 or i >= _poses.size():
		return
	var pose := {}
	for b in _skel.get_bone_count():
		pose[b] = _skel.get_bone_pose_rotation(b)
	var hips := _resolve_bone("mixamorig_Hips")
	if hips != -1:
		pose["_root_pos"] = _skel.get_bone_pose_position(hips)
		pose["_root_bone"] = hips
	_poses[i] = pose
	_flash_hud("Checkpoint %d updated." % (i + 1))


func _delete_pose(i: int) -> void:
	if i < 0 or i >= _poses.size():
		return
	_poses.remove_at(i)
	_durations.remove_at(i)
	# The new first checkpoint never has an incoming segment.
	if _durations.size() > 0:
		_durations[0] = 0.0
	_selected_pose = clampi(_selected_pose, -1, _poses.size() - 1)
	_show_hud()
	_rebuild_timeline()


# ── Timeline panel (checkpoints + per-segment speed + mini bar) ───────────
func _build_timeline() -> void:
	if _timeline_panel != null:
		return
	_ensure_ui_layer()

	var panel := PanelContainer.new()
	# Bottom-left, so it never collides with the corner controls cheat-sheet or
	# the pose-mode help label (both top-left).
	panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	panel.offset_left = 12.0
	panel.offset_right = 300.0
	panel.offset_bottom = -12.0
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.55)
	sb.set_content_margin_all(10.0)
	sb.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", sb)
	_ui_layer.add_child(panel)
	_timeline_panel = panel

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	col.custom_minimum_size = Vector2(276, 0)
	panel.add_child(col)

	var title := Label.new()
	title.text = "CHECKPOINTS"
	title.add_theme_color_override("font_color", active_color)
	col.add_child(title)

	# Mini visual timeline bar (markers spaced by cumulative time + playhead).
	_timeline_bar = Control.new()
	_timeline_bar.custom_minimum_size = Vector2(276, 26)
	_timeline_bar.draw.connect(_draw_timeline_bar)
	col.add_child(_timeline_bar)

	_timeline_summary = Label.new()
	_timeline_summary.add_theme_color_override("font_color", Color(0.8, 0.92, 1.0))
	col.add_child(_timeline_summary)

	# Scrollable list of per-checkpoint rows.
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(276, 190)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_timeline_rows = VBoxContainer.new()
	_timeline_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_timeline_rows.add_theme_constant_override("separation", 3)
	scroll.add_child(_timeline_rows)

	var hint := Label.new()
	hint.text = "Click # to view · ▲ re-record · ✕ delete\nspeed box = seconds into that point"
	hint.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	hint.add_theme_font_size_override("font_size", 11)
	col.add_child(hint)


## Rebuild the per-checkpoint rows + redraw the bar. Cheap enough to call on any
## change (freeze / delete / jump / retime).
func _rebuild_timeline() -> void:
	if _timeline_rows == null:
		return
	for c in _timeline_rows.get_children():
		c.queue_free()

	for i in _poses.size():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)

		# Index button — click to jump the skeleton to this checkpoint.
		var jump := Button.new()
		jump.text = str(i + 1)
		jump.custom_minimum_size = Vector2(34, 0)
		jump.toggle_mode = true
		jump.button_pressed = (i == _selected_pose)
		jump.tooltip_text = "View checkpoint %d" % (i + 1)
		jump.pressed.connect(_jump_to_pose.bind(i))
		row.add_child(jump)

		# Per-segment duration (seconds INTO this checkpoint). Disabled for #1.
		var spin := SpinBox.new()
		spin.min_value = SEG_MIN
		spin.max_value = SEG_MAX
		spin.step = 0.05
		spin.custom_minimum_size = Vector2(78, 0)
		if i == 0:
			spin.editable = false
			spin.prefix = "t0 "
			spin.value = SEG_MIN
		else:
			spin.suffix = "s"
			spin.value = clampf(float(_durations[i]), SEG_MIN, SEG_MAX)
			spin.value_changed.connect(_on_duration_changed.bind(i))
		spin.tooltip_text = "Seconds to travel from the previous checkpoint to this one (lower = faster)."
		row.add_child(spin)

		# Cumulative time readout.
		var t_lbl := Label.new()
		t_lbl.text = "@%.2fs" % _pose_time(i)
		t_lbl.custom_minimum_size = Vector2(56, 0)
		t_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.6))
		row.add_child(t_lbl)

		# Re-record this checkpoint from the live pose.
		var rec := Button.new()
		rec.text = "▲"
		rec.tooltip_text = "Overwrite this checkpoint with the current pose"
		rec.pressed.connect(_replace_pose.bind(i))
		row.add_child(rec)

		# Delete.
		var del := Button.new()
		del.text = "✕"
		del.tooltip_text = "Delete this checkpoint"
		del.pressed.connect(_delete_pose.bind(i))
		row.add_child(del)

		_timeline_rows.add_child(row)

	_timeline_summary.text = "%d points · %.2fs total" % [_poses.size(), _total_time()]
	if _timeline_bar:
		_timeline_bar.queue_redraw()


func _on_duration_changed(value: float, i: int) -> void:
	if i >= 0 and i < _durations.size():
		_durations[i] = clampf(value, SEG_MIN, SEG_MAX)
		# Refresh cumulative-time labels + bar without rebuilding the whole list
		# (which would steal focus from the SpinBox being edited). Bound by the pose
		# count: a just-deleted row may linger one frame (queue_free is deferred),
		# so iterating raw children could index past the checkpoints.
		var n := mini(_timeline_rows.get_child_count(), _poses.size())
		for k in n:
			var row := _timeline_rows.get_child(k)
			if row.is_queued_for_deletion():
				continue
			# 3rd child is the "@t" label (jump, spin, t_lbl, ...).
			if row.get_child_count() > 2:
				(row.get_child(2) as Label).text = "@%.2fs" % _pose_time(k)
		if _timeline_summary:
			_timeline_summary.text = "%d points · %.2fs total" % [_poses.size(), _total_time()]
		if _timeline_bar:
			_timeline_bar.queue_redraw()


## Draw the mini timeline: a track line, a dot per checkpoint positioned by its
## cumulative time, the selected one highlighted, and a moving playhead during
## preview.
func _draw_timeline_bar() -> void:
	var bar := _timeline_bar
	var w := bar.size.x
	var h := bar.size.y
	var cy := h * 0.5
	var pad := 8.0
	bar.draw_line(Vector2(pad, cy), Vector2(w - pad, cy), Color(0.5, 0.6, 0.7), 2.0)

	var total := _total_time()
	for i in _poses.size():
		var f := 0.0 if total <= 0.0 else _pose_time(i) / total
		var x := lerpf(pad, w - pad, f)
		var col := active_color if i == _selected_pose else Color(0.4, 0.75, 1.0)
		bar.draw_circle(Vector2(x, cy), 5.0, col)

	# Playhead during preview.
	if _previewing and total > 0.0 and _anim_player and _anim_player.is_playing():
		var f := clampf(_anim_player.current_animation_position / total, 0.0, 1.0)
		var x := lerpf(pad, w - pad, f)
		bar.draw_line(Vector2(x, 2.0), Vector2(x, h - 2.0), Color(1, 0.9, 0.2), 2.0)
