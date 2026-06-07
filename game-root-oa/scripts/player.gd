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

@export_group("Spells")
## Authored spell-cast clips (made with the in-game pose tool). Each .tres is
## loaded into the AnimationPlayer at startup under its file name (e.g.
## "spell_cast"). The Cast key (Q) plays one of these as the cast ANIMATION; the
## rig is the same Mixamo X_Bot the clips were authored on, so they drop straight
## in. Index by `active_spell`, falling back to clip 0 if a spell has no own clip.
@export var spell_clips: Array[Animation] = []
## The spells themselves (VFX + behaviour). Each .tres is a SpellProfile — the
## mesh/shader/emit-mode. The active one (1/2/3 keys) is what Q casts. Kept
## separate from spell_clips so one cast animation can serve several spells.
@export var spells: Array[SpellProfile] = []
## Which spell the Cast key casts (index into `spells`, set by the 1/2/3 keys).
@export var active_spell: int = 0
## Spell-cast animation speed during the WINDUP (you asked for 2× = snappy). The
## channel loop (while holding) plays at normal speed; see _cast / _channel.
@export var cast_speed_scale: float = 2.0
## Seconds of the cast clip's TAIL that loop while channelling a held spell. The
## windup is everything before this; the last `channel_loop_secs` repeat at
## normal speed for as long as the cast key is held.
@export var channel_loop_secs: float = 1.0

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
var _muzzle: Marker3D            ## spell emitter at the sword tip (rides the hand bone)
var _combo_index: int = 0        ## which light hit/lunge is active
var _state_clip: String = ""     ## the action clip the current state is waiting on
var _lunge_vel: Vector3 = Vector3.ZERO  ## active forward lunge (XZ), decays over the swing
var _blur_hold: bool = false     ## freeze speed-blur at its current strength (sprint-attack)
var _sprint_attack_fov_suppressed: bool = false  ## sprint-attacks drop camera FOV punch

# --- Spells ---------------------------------------------------------------
var _spell_names: PackedStringArray = []  ## clip names loaded from spell_clips
var _casting: bool = false                ## a cast clip is currently playing
var _cast_clip: String = ""               ## the clip name we're waiting to finish
@onready var _spell_caster := $SpellCaster   ## spawns spell VFX (added in player.tscn)
## A cast is queued because we had to draw the sword first; fired on UNSHEATHING→READY.
var _pending_cast: bool = false
## We're past the windup and now looping the clip's tail because the key is held.
var _channelling: bool = false
## A projectile shot has already been spawned this cast (so it fires exactly once).
var _cast_fired: bool = false
## True between key-down and the moment we decide tap-vs-hold (windup not finished).
var _cast_held: bool = false
## The SpellProfile this cast is using (resolved at key-down from active_spell).
var _cast_spell: SpellProfile
## Absolute time in the cast clip where the channel loop begins (windup end).
var _channel_loop_start: float = 0.0
var _cast_clip_len: float = 0.0
## DEBUG: hold B to force the active spell's beam ON (no animation), so the muzzle
## marker can be dragged in the running editor and the beam follows it live. The
## beam parents to the muzzle, so moving the marker re-aims it instantly. Remove
## this + the `debug_channel` input action when muzzle tuning is done.
var _debug_channel: bool = false


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
	_load_spells()
	# Hand the spell emitter (sword-tip muzzle) to the caster so spells spawn there.
	if _spell_caster and _muzzle:
		_spell_caster.set_muzzle(_muzzle)
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

	# Spell emitter ("muzzle"): a Marker3D named "SpellMuzzle" authored INSIDE the
	# sword scene (scenes/sword_real.tscn). You drag it to the blade tip in the
	# editor and see it live; the player just finds it. Spells fire along its local
	# -Z. The cyan Gizmo child is its visible marker — delete that child (or hide
	# it) for release; the muzzle itself is invisible without it.
	_muzzle = _sword.find_child("SpellMuzzle", true, false) as Marker3D
	if _muzzle == null:
		push_warning("Player: no 'SpellMuzzle' Marker3D in the weapon scene; spells will have no emitter.")


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var found := _find_skeleton(c)
		if found:
			return found
	return null


# --- Spells ---------------------------------------------------------------
## Load each authored spell clip into the AnimationPlayer's default library so it
## can be played by name. Names come from the resource file ("spell_cast.tres"
## → "spell_cast"); falls back to "spell_<i>" if the path can't be read.
func _load_spells() -> void:
	if spell_clips.is_empty():
		return
	var lib := _anim.get_animation_library("")
	if lib == null:
		lib = AnimationLibrary.new()
		_anim.add_animation_library("", lib)
	for i in spell_clips.size():
		var clip := spell_clips[i]
		if clip == null:
			continue
		var nm := clip.resource_path.get_file().get_basename()
		if nm == "":
			nm = "spell_%d" % i
		if lib.has_animation(nm):
			lib.remove_animation(nm)
		lib.add_animation(nm, clip)
		_spell_names.append(nm)


## Set the active spell slot (1/2/3 keys). Clamped to the configured spells.
func _select_spell(index: int) -> void:
	if index < 0 or index >= spells.size():
		return
	active_spell = index
	# Let any spell-bar HUD react. The bar listens on this group.
	get_tree().call_group("spell_bar", "set_active_spell", active_spell)


## The cast clip name for the active spell: its own clip if `spell_clips` has one
## at that index, else the first loaded clip (one animation can serve many spells).
func _active_cast_clip() -> String:
	if _spell_names.is_empty():
		return ""
	var i := active_spell if active_spell < _spell_names.size() else 0
	return _spell_names[i]


## The active SpellProfile (the VFX/behaviour), or null if none configured.
func _active_spell_profile() -> SpellProfile:
	if active_spell >= 0 and active_spell < spells.size():
		return spells[active_spell]
	return null


# ── Cast key down / up ─────────────────────────────────────────────────────
## Q pressed: begin the cast windup. If the sword is sheathed we must draw it
## first (spells emit from the blade tip) — the cast is queued and fires when the
## unsheath finishes. Tap-vs-hold is decided later: a beam spell channels while
## held, a projectile spell fires once when the windup ends or the key releases.
func _cast_pressed() -> void:
	_cast_held = true
	# Already mid-action (attack / sheath / cast): ignore, don't interrupt.
	if _casting or _combat == Combat.ATTACKING \
			or _combat == Combat.UNSHEATHING or _combat == Combat.SHEATHING:
		return
	_cast_spell = _active_spell_profile()
	if _combat == Combat.SHEATHED:
		# ER-style: casting draws the sword first, then the cast auto-fires.
		_pending_cast = true
		_enter_unsheathing()
		return
	_begin_cast()


## Q released: stop channelling. A held beam ends; a projectile that hasn't fired
## yet (released during windup) still fires when the windup completes.
func _cast_released() -> void:
	_cast_held = false
	if _channelling:
		_channelling = false
		_spell_caster.end_beam()
		# Let the clip play out from the loop tail back to its end at windup speed.
		_anim.speed_scale = 1.0
		if _anim.has_animation(_cast_clip):
			_anim.play(_cast_clip, 0.1, cast_speed_scale)
			_anim.seek(_channel_loop_start, true)


# ── DEBUG: hold-to-channel for muzzle tuning ───────────────────────────────
## B pressed: force the active spell's beam on immediately (no cast animation),
## drawing the sword first if needed so the muzzle exists. The beam parents to the
## muzzle marker, so while it's up you can drag SpellMuzzle in the running editor
## and watch the beam re-aim live. Falls back to a beam even for projectile spells
## so any spell can be used to eyeball the emitter.
func _debug_channel_start() -> void:
	_debug_channel = true
	if _combat == Combat.SHEATHED:
		_enter_unsheathing()        # need the blade out so the muzzle is visible


## B released: kill the debug beam.
func _debug_channel_stop() -> void:
	_debug_channel = false
	_spell_caster.end_beam()


## Drive the debug beam each frame: keep it alive while B is held + the muzzle
## exists, so it survives the unsheath and tracks the marker.
func _update_debug_channel() -> void:
	if not _debug_channel:
		return
	if not _spell_caster.has_muzzle():
		return
	var profile := _active_spell_profile()
	if profile == null:
		return
	# begin_beam is a no-op if this exact profile's beam is already up, and rebuilds
	# if you switched spells (1/2/3) mid-hold, so any spell can be previewed.
	_spell_caster.begin_beam(profile)


## Start the cast animation windup at 2× speed. Records where the channel tail
## begins so _process can switch to the looped channel if the key is still held.
func _begin_cast() -> void:
	var clip := _active_cast_clip()
	if clip == "" or not _anim.has_animation(clip):
		return
	_casting = true
	_channelling = false
	_cast_fired = false
	_cast_clip = clip
	_current_anim = clip
	_cast_clip_len = _anim.get_animation(clip).length
	_channel_loop_start = maxf(0.0, _cast_clip_len - channel_loop_secs)
	_anim.speed_scale = 1.0
	_anim.play(clip, 0.15, cast_speed_scale)


## Tear down all cast state and restore normal animation playback. Called when the
## cast clip finishes (or is cancelled).
func _end_cast() -> void:
	_casting = false
	_channelling = false
	_cast_fired = false
	_cast_clip = ""
	_cast_spell = null
	_current_anim = ""            # force a fresh crossfade back to locomotion
	_anim.speed_scale = 1.0       # undo the channel slow-down
	_spell_caster.end_beam()


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
		# Spell-bar selection: 1/2/3 pick which spell the Cast key (Q) uses.
		if event.is_action_pressed("spell_slot_1"):
			_select_spell(0)
		elif event.is_action_pressed("spell_slot_2"):
			_select_spell(1)
		elif event.is_action_pressed("spell_slot_3"):
			_select_spell(2)
		elif event.is_action_pressed("cast_spell"):
			_cast_pressed()
		elif event.is_action_released("cast_spell"):
			_cast_released()
		elif event.is_action_pressed("debug_channel"):
			_debug_channel_start()
		elif event.is_action_released("debug_channel"):
			_debug_channel_stop()
		else:
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
	if _casting and String(anim_name) == _cast_clip:
		# If the key is still held on a BEAM spell we keep channelling — the tail is
		# re-seeked in _update_cast, so a "finished" here just means a loop wrapped.
		if _channelling and _cast_held:
			return
		_end_cast()
		return
	if String(anim_name) == _state_clip and _state_clip != "":
		_advance_combat_state()


## Advance out of a transient combat state (driven by clip-finished, or instantly
## when the clip doesn't exist yet).
func _advance_combat_state() -> void:
	match _combat:
		Combat.UNSHEATHING:
			_combat = Combat.READY
			# A cast that was waiting on the draw now fires (ER-style auto-unsheath).
			if _pending_cast:
				_pending_cast = false
				_begin_cast()
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
	return _casting \
		or _combat == Combat.ATTACKING \
		or _combat == Combat.UNSHEATHING \
		or _combat == Combat.SHEATHING


## Drive the cast windup → fire/channel transition each frame. When the cast clip
## reaches the channel-loop point (windup done): a PROJECTILE spell fires one shot
## and the cast plays out; a BEAM spell, if the key is still held, starts the beam
## and loops the clip's tail (at normal speed) until release.
func _update_cast() -> void:
	if not _casting:
		return
	# Already channelling: keep the beam alive and re-loop the tail while held.
	if _channelling:
		if not _cast_held:
			return                            # release handled in _cast_released
		var pos := _anim.current_animation_position
		if pos >= _cast_clip_len - 0.02:
			# Loop the tail at normal speed for a sustained channel pose.
			_anim.seek(_channel_loop_start, true)
		return

	# Windup phase: watch for the playhead crossing the channel-loop start.
	if _current_anim != _cast_clip or _cast_fired:
		return
	if _anim.current_animation_position >= _channel_loop_start:
		var profile := _cast_spell if _cast_spell else _active_spell_profile()
		if profile == null:
			_cast_fired = true
			return
		if profile.emit_mode == SpellProfile.EmitMode.BEAM and _cast_held:
			# Channel: sustain the beam and slow the clip to normal speed for the loop.
			_channelling = true
			_cast_fired = true
			_anim.speed_scale = (1.0 / cast_speed_scale) if cast_speed_scale != 0.0 else 1.0
			_spell_caster.begin_beam(profile)
		else:
			# Tap (or projectile spell): fire one shot; the clip plays out normally.
			_cast_fired = true
			_spell_caster.cast_projectile(profile)


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

	_update_cast()
	_update_debug_channel()

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
	elif _casting:
		# Casting: rooted in place (you asked for "can't move while casting") but the
		# body can still TURN to aim the spell. Hard-zero horizontal velocity.
		velocity.x = 0.0
		velocity.z = 0.0
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
	if _casting:
		# Aim the cast: turn the body toward where you're steering, else toward the
		# camera's forward, so you can re-aim a held beam / pick a projectile's line.
		var aim := dir
		if aim.length() < 0.1:
			aim = forward          # camera-forward flattened to XZ (computed above)
		if aim.length() > 0.1:
			var want_yaw := atan2(aim.x, aim.z)
			_body.rotation.y = lerp_angle(_body.rotation.y, want_yaw, rotation_speed * delta)
	elif dir.length() > 0.1 and not _is_action_locked():
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
