extends CharacterBody3D
## One Accord — third-person player controller (GTA-style).
##
## Movement is camera-relative: WASD pushes the character along the ground in the
## direction the CAMERA faces, and the visual body smoothly rotates to face the
## way it is moving. The camera orbits the player on a SpringArm3D driven by the
## mouse (yaw + clamped pitch); the spring arm collides with the terrain so the
## camera never clips through hills.
##
## CAMERA SMOOTHNESS: mouse-look is applied in _process (per render frame) so it
## never stutters, while movement/physics run in _physics_process. The project
## has physics interpolation ON so the body's mesh and the camera rig don't snap
## between the 60 Hz physics ticks at high speed (the "ping lag" on sprint).
##
## Scene layout this script expects (see scenes/player.tscn):
##   Player (CharacterBody3D, this script)
##   ├── Body            (Node3D)  ← visual root (the Mixamo X_Bot)
##   │   └── X_Bot/Skeleton3D/...
##   ├── Collision       (CollisionShape3D, capsule)
##   └── CameraPivot     (Node3D)  ← sits at the player's origin, yaws/pitches
##       └── SpringArm3D            ← pushes the camera back, collides w/ world
##           └── Camera3D

# --- Tunables -------------------------------------------------------------
@export_group("Movement")
@export var walk_speed: float = 6.0
@export var sprint_speed: float = 11.0
@export var acceleration: float = 12.0     ## how fast we reach target velocity
@export var rotation_speed: float = 12.0   ## how fast the body turns to face travel
@export var jump_velocity: float = 5.5
@export var gravity: float = 18.0

@export_group("Camera")
@export var mouse_sensitivity: float = 0.0025
@export var pitch_min_deg: float = -55.0
@export var pitch_max_deg: float = 75.0
@export var arm_length: float = 5.0

@export_group("Sprint feel")
@export var base_fov: float = 75.0          ## camera FOV at rest / walking
@export var sprint_fov: float = 88.0        ## camera FOV at full sprint (the "zoom")
@export var fov_lerp_speed: float = 6.0     ## how fast FOV eases in/out
@export var blur_lerp_speed: float = 8.0    ## how fast the speed-blur eases in/out

@export_group("Combat")
## All weapon data — which clips map to which actions, the mesh, the grip — lives
## in this resource (see scripts/weapon_profile.gd). Swap it to change weapons
## without touching this script. Null = unarmed (combat input is ignored).
@export var weapon_profile: WeaponProfile
## Movement is scaled by this while an attack/draw clip plays (0 = rooted).
@export var attack_move_damp: float = 0.15

# --- Pose authoring -------------------------------------------------------
## Set true by the in-game pose tool (scripts/pose_animator.gd). While active the
## controller surrenders ALL control: no movement, no combat input, no camera
## look, and it stops driving the AnimationPlayer so the tool owns the skeleton.
var pose_mode_active: bool = false

# --- Nodes ----------------------------------------------------------------
@onready var _body: Node3D = $Body
@onready var _pivot: Node3D = $CameraPivot
@onready var _spring: SpringArm3D = $CameraPivot/SpringArm3D
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _anim: AnimationPlayer = $Body/X_Bot/AnimationPlayer

var _yaw: float = 0.0     ## camera yaw (around Y), radians
var _pitch: float = 0.0   ## camera pitch, radians
var _current_anim: String = ""
var _air_jump: String = "jump"   ## which jump clip is mid-air (set at takeoff)
var _sprint_factor: float = 0.0  ## smoothed 0..1, how "sprinting" we look right now
var _blur_mat: ShaderMaterial    ## fullscreen speed-blur material, driven each frame

# --- Combat ---------------------------------------------------------------
# State machine only; the actual motion comes from authored clips whose NAMES
# come from `weapon_profile` (never hard-coded here). A clip that isn't in the
# library makes its transition resolve instantly (no motion, no soft-lock).
enum Combat { SHEATHED, UNSHEATHING, READY, SHEATHING, ATTACKING }
var _combat: Combat = Combat.SHEATHED
var _sword: Node3D               ## the attached weapon instance (may be null)
var _combo_index: int = 0        ## which light hit/lunge is active
var _state_clip: String = ""     ## the action clip the current state is waiting on
var _lunge_vel: Vector3 = Vector3.ZERO  ## active forward lunge (XZ), decays over the swing
var _blur_hold: bool = false     ## freeze speed-blur at its current strength (sprint-attack)
var _sprint_attack_fov_suppressed: bool = false  ## sprint-attacks drop camera FOV punch


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_spring.spring_length = arm_length
	# Don't let the spring arm collide with the player's own body.
	_spring.add_excluded_object(get_rid())
	_camera.fov = base_fov
	# Grab the fullscreen speed-blur material (a ColorRect in the HUD, tagged
	# "speed_blur") so we can ramp its strength with sprint. Safe if absent.
	var blur := get_tree().get_first_node_in_group("speed_blur") as CanvasItem
	if blur and blur.material is ShaderMaterial:
		_blur_mat = blur.material

	_attach_sword()
	# Connect attack/sheath clips so state transitions fire when a REAL clip ends.
	_anim.animation_finished.connect(_on_anim_finished)
	_play("idle")

	# The spawn position is a teleport; without this, physics interpolation
	# smears the body across the screen on the very first frame.
	reset_physics_interpolation()

	# Guarantee terrain collision at runtime. The Terrain3D editor plugin tends to
	# strip collision_enabled/collision_mode from world.tscn on re-save, so we
	# force a full static bake here (mode 3 = Full/Game) instead of trusting the
	# scene. Full bake = one upfront cost, then NO per-frame collision streaming —
	# which is what caused the "catch and snap" stutter with the dynamic mode.
	var terrain := get_tree().get_first_node_in_group("terrain") as Terrain3D
	if terrain == null:
		# Fall back to a direct lookup if the group isn't set.
		var w := get_parent()
		if w:
			terrain = w.get_node_or_null("Terrain3D") as Terrain3D
	if terrain:
		# Collision is enabled simply by a non-zero mode. 3 = Full / Game.
		terrain.collision_mode = 3


## Find the skeleton, hang a BoneAttachment3D off the hand bone named by the
## weapon profile, and parent the weapon mesh to it. Starts hidden (sheathed).
## Robust to bone-name variants.
func _attach_sword() -> void:
	if weapon_profile == null or weapon_profile.weapon_scene == null:
		return
	var skel := _find_skeleton(_body)
	if skel == null:
		push_warning("Player: no Skeleton3D found under Body; weapon not attached.")
		return

	# Resolve the hand bone, trying the profile's name then common variants.
	var bone := skel.find_bone(weapon_profile.hand_bone)
	if bone == -1:
		for alt in ["mixamorig_RightHand", "mixamorig:RightHand", "RightHand", "Hand_R"]:
			bone = skel.find_bone(alt)
			if bone != -1:
				break
	if bone == -1:
		push_warning("Player: right-hand bone not found; weapon not attached.")
		return

	var attach := BoneAttachment3D.new()
	attach.name = "SwordSocket"
	skel.add_child(attach)
	attach.bone_idx = bone

	_sword = weapon_profile.weapon_scene.instantiate()
	attach.add_child(_sword)
	_sword.position = weapon_profile.grip_offset
	_sword.rotation = Vector3(
		deg_to_rad(weapon_profile.grip_rotation_deg.x),
		deg_to_rad(weapon_profile.grip_rotation_deg.y),
		deg_to_rad(weapon_profile.grip_rotation_deg.z))
	_sword.visible = false   # sheathed at spawn


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var found := _find_skeleton(c)
		if found:
			return found
	return null


func _unhandled_input(event: InputEvent) -> void:
	if pose_mode_active:
		# The pose tool owns most input, but camera-look still works via RIGHT-drag
		# (left-click is reserved for picking/dragging handles). Only motion that
		# the pose tool didn't consume reaches here.
		if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_yaw -= event.relative.x * mouse_sensitivity
			_pitch -= event.relative.y * mouse_sensitivity
			_pitch = clampf(_pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clampf(_pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
	elif event.is_action_pressed("ui_cancel"):
		# Esc toggles the mouse free so you can click around the editor/UI.
		Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED)
	elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_combat_input(event)


## Discrete combat buttons: draw/sheath the sword and start swings.
func _combat_input(event: InputEvent) -> void:
	if weapon_profile == null:
		return   # unarmed: no combat
	if event.is_action_pressed("sheath_toggle"):
		if _combat == Combat.READY:
			_enter_sheathing()
		elif _combat == Combat.SHEATHED:
			_enter_unsheathing()
		return

	if _sword == null:
		return

	if event.is_action_pressed("attack_light"):
		if _combat == Combat.SHEATHED:
			_enter_unsheathing()          # ER-style: attacking draws first
		elif _combat == Combat.READY:
			# Sprint-light jumps straight to the rotating jump swing after the
			# third light hit. Standing starts at 1.
			_start_light(4 if _is_sprint_moving() else 1)
	elif event.is_action_pressed("attack_heavy"):
		if _combat == Combat.SHEATHED:
			_enter_unsheathing()
		elif _combat == Combat.READY:
			_start_heavy()                # same clip; sprint just adds lunge+blur


# --- Combat state machine -------------------------------------------------
# Action states play a clip named below if it exists. If the clip is NOT yet
# authored, the transition resolves instantly (no motion) so nothing soft-locks.
# Real clips drive the state via animation_finished.

func _enter_unsheathing() -> void:
	_combat = Combat.UNSHEATHING
	if _sword:
		_sword.visible = true
	_begin_action(weapon_profile.unsheath)


func _enter_sheathing() -> void:
	_combat = Combat.SHEATHING
	_begin_action(weapon_profile.sheath)


func _start_light(index: int) -> void:
	_combat = Combat.ATTACKING
	_combo_index = clampi(index, 1, weapon_profile.light_combo_len())
	_set_lunge(weapon_profile.light_lunge_speed(_combo_index))
	_begin_action(weapon_profile.light_clip(_combo_index))


func _start_heavy() -> void:
	_combat = Combat.ATTACKING
	_combo_index = 0   # heavy is not part of the light chain
	_set_lunge(weapon_profile.heavy_lunge)
	_begin_action(weapon_profile.heavy)


## Kick off a forward lunge for the attack that's starting. Direction is the
## player's current movement intent if any (camera-relative input), else the
## body's current facing. Speed is `base_speed` plus a slice of whatever planar
## speed we carried in (so sprinting into an attack travels further). The body
## also snaps to face the lunge so the swing reads correctly. Decays in _move.
func _set_lunge(base_speed: float) -> void:
	var lunge_dir := _intended_dir()
	if lunge_dir.length() < 0.01:
		# Standing still: lunge along the body's CURRENT visual facing. The body's
		# yaw is set via atan2(dir.x, dir.z) (see _move), so its forward vector is
		# (sin yaw, 0, cos yaw) — NOT -basis.z (that pointed back at the camera).
		var y := _body.rotation.y
		lunge_dir = Vector3(sin(y), 0.0, cos(y))
	lunge_dir = lunge_dir.normalized()
	# Face the lunge (committed swings don't steer the body afterwards).
	_body.rotation.y = atan2(lunge_dir.x, lunge_dir.z)
	# Attacking out of a sprint: hold the speed-blur up through the swing (the
	# sprint motion itself stops because the lunge overrides movement).
	if _is_sprint_moving():
		_blur_hold = true
		_sprint_attack_fov_suppressed = true
	var carried := Vector2(velocity.x, velocity.z).length() * weapon_profile.sprint_carry
	_lunge_vel = lunge_dir * (base_speed + carried)


## True if the player is currently sprinting AND actually moving fast (the same
## condition that drives the sprint FOV/blur). Used to branch attacks.
func _is_sprint_moving() -> bool:
	var planar := Vector2(velocity.x, velocity.z).length()
	return Input.is_action_pressed("sprint") and planar > walk_speed + 0.5


## Camera-relative movement intent on the XZ plane (same math as _move), or zero
## if no movement keys are held.
func _intended_dir() -> Vector3:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input.length() < 0.01:
		return Vector3.ZERO
	var cam_basis := _pivot.global_transform.basis
	var forward := -cam_basis.z
	var right := cam_basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	return (right * input.x - forward * input.y).normalized()


## Play the action clip if it exists (it then drives the state via
## animation_finished). If it's missing, resolve the state immediately.
func _begin_action(clip: String) -> void:
	_state_clip = clip
	if clip != "" and _anim.has_animation(clip):
		_current_anim = clip
		# Mixamo swings are slow — speed up attack/draw/sheath playback.
		_anim.play(clip, weapon_profile.action_blend, weapon_profile.attack_speed_scale)
	else:
		_advance_combat_state()


## Called when an animation finishes. Only react if it's the action clip the
## current state is waiting on (locomotion clips loop / get interrupted instead).
func _on_anim_finished(anim_name: StringName) -> void:
	if String(anim_name) == _state_clip and _state_clip != "":
		_advance_combat_state()


## Advance out of a transient combat state (driven by clip-finished, or instantly
## when the clip doesn't exist yet).
func _advance_combat_state() -> void:
	match _combat:
		Combat.UNSHEATHING:
			_combat = Combat.READY
		Combat.SHEATHING:
			_combat = Combat.SHEATHED
			if _sword:
				_sword.visible = false
		Combat.ATTACKING:
			_combat = Combat.READY
			_blur_hold = false   # swing over — let the speed-blur fade out
			_sprint_attack_fov_suppressed = false
	_state_clip = ""


## True while the player shouldn't get full movement control.
func _is_action_locked() -> bool:
	return _combat == Combat.ATTACKING \
		or _combat == Combat.UNSHEATHING \
		or _combat == Combat.SHEATHING


## Camera orbit runs every RENDER frame, not every physics tick, so mouse-look
## stays perfectly smooth regardless of physics rate.
func _process(delta: float) -> void:
	if pose_mode_active:
		# Still orbit the camera while posing (mouse is free to click handles, so
		# camera-look is bound to right-drag — see _unhandled_input). Skip the
		# movement/FOV/blur work; just keep the pivot following yaw/pitch.
		_pivot.rotation.y = _yaw
		_pivot.rotation.x = _pitch
		return
	_pivot.rotation.y = _yaw
	_pivot.rotation.x = _pitch

	# Sprint feel: ease toward 1.0 when actually sprinting + moving fast, else 0.
	var planar := Vector2(velocity.x, velocity.z).length()
	var sprinting := Input.is_action_pressed("sprint") and planar > walk_speed + 0.5
	var target := 1.0 if sprinting and not _sprint_attack_fov_suppressed else 0.0
	_sprint_factor = move_toward(_sprint_factor, target, fov_lerp_speed * delta)

	_camera.fov = lerpf(base_fov, sprint_fov, _sprint_factor)
	if _blur_mat:
		var cur: float = _blur_mat.get_shader_parameter("strength")
		# While holding (sprint-attack), freeze the blur at its current strength;
		# otherwise ease it toward the live sprint factor (fades after the swing).
		if not _blur_hold:
			_blur_mat.set_shader_parameter("strength",
				move_toward(cur, _sprint_factor, blur_lerp_speed * delta))


func _physics_process(delta: float) -> void:
	if pose_mode_active:
		# Hold still and let the pose tool drive the skeleton. Still apply gravity
		# so we don't float, but zero out horizontal motion and skip anim updates.
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0.0
		move_and_slide()
		return
	_move(delta)


func _move(delta: float) -> void:
	var was_on_floor := is_on_floor()

	# Gravity + jump. Record which jump clip to hold in the air based on whether
	# we were moving fast at takeoff (running jump vs. standing jump).
	if not was_on_floor:
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		var planar := Vector2(velocity.x, velocity.z).length()
		var base_jump := "run_jump" if planar > walk_speed + 0.5 else "jump"
		_air_jump = _jump_clip(base_jump)

	# Camera-relative ground input. Flatten the camera basis onto the XZ plane so
	# looking up/down doesn't change how far "forward" pushes.
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var cam_basis := _pivot.global_transform.basis
	var forward := -cam_basis.z
	var right := cam_basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	# input.y is +1 for "back" (move_back) and -1 for "forward" (move_forward),
	# so SUBTRACT it to make W push along +forward. (Fixes inverted W/S.)
	var dir := (right * input.x - forward * input.y)
	if dir.length() > 1.0:
		dir = dir.normalized()

	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	if _combat == Combat.ATTACKING:
		# Attacks lunge: the body coasts along the decaying lunge velocity set when
		# the swing started (carrying sprint momentum). Tiny input steering is
		# allowed on top so you can curve the lunge slightly, but you can't just
		# walk during a committed swing.
		_lunge_vel = _lunge_vel.move_toward(Vector3.ZERO, weapon_profile.lunge_decay * delta)
		var steer := dir * walk_speed * attack_move_damp
		velocity.x = _lunge_vel.x + steer.x
		velocity.z = _lunge_vel.z + steer.z
	elif _is_action_locked():
		# Drawing / sheathing: nearly rooted (small ER-style drift) so it commits.
		var target := dir * speed * attack_move_damp
		velocity.x = move_toward(velocity.x, target.x, acceleration * speed * delta)
		velocity.z = move_toward(velocity.z, target.z, acceleration * speed * delta)
	else:
		var target := dir * speed
		# Smoothly approach the target horizontal velocity (accel/decel feel).
		velocity.x = move_toward(velocity.x, target.x, acceleration * speed * delta)
		velocity.z = move_toward(velocity.z, target.z, acceleration * speed * delta)

	move_and_slide()

	# Rotate the visual body to face the travel direction (GTA-style). Don't spin
	# while committed to a swing.
	if dir.length() > 0.1 and not _is_action_locked():
		var want_yaw := atan2(dir.x, dir.z)
		_body.rotation.y = lerp_angle(_body.rotation.y, want_yaw, rotation_speed * delta)

	_update_anim(dir, speed, is_on_floor())


## Pick the animation that matches the current motion and crossfade to it.
## Action states (attacking / sheathing) own the AnimationPlayer — leave them be.
func _update_anim(dir: Vector3, speed: float, on_floor: bool) -> void:
	if _is_action_locked():
		return

	var clip := "idle"
	if not on_floor:
		clip = _air_jump   # "jump" or "run_jump", chosen at takeoff
	elif dir.length() > 0.1:
		clip = "run" if speed >= sprint_speed else "walk"

	# When the weapon is drawn, prefer the armed variant of the locomotion clip,
	# falling back to the unarmed clip if that variant isn't in the library.
	if _combat == Combat.READY:
		clip = _armed(clip)
	_play(clip)


## Map a base locomotion clip to its weapon-armed variant (per the profile) if
## that clip exists in the library, else keep the unarmed base.
func _armed(base: String) -> String:
	if weapon_profile == null:
		return base
	var variant := weapon_profile.armed_variant(base)
	return variant if _anim.has_animation(variant) else base


func _jump_clip(base: String) -> String:
	if base != "jump" or weapon_profile == null:
		return base
	var variant := weapon_profile.armed_variant(base)
	return variant if _anim.has_animation(variant) else base


func _play(clip: String) -> void:
	if clip == _current_anim:
		return
	if not _anim.has_animation(clip):
		return
	_current_anim = clip
	# Longer blend time = smoother crossfades between locomotion states.
	var blend := weapon_profile.locomotion_blend if weapon_profile else 0.25
	_anim.play(clip, blend)
