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


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clampf(_pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
	elif event.is_action_pressed("ui_cancel"):
		# Esc toggles the mouse free so you can click around the editor/UI.
		Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED)


## Camera orbit runs every RENDER frame, not every physics tick, so mouse-look
## stays perfectly smooth regardless of physics rate.
func _process(delta: float) -> void:
	_pivot.rotation.y = _yaw
	_pivot.rotation.x = _pitch

	# Sprint feel: ease toward 1.0 when actually sprinting + moving fast, else 0.
	var planar := Vector2(velocity.x, velocity.z).length()
	var sprinting := Input.is_action_pressed("sprint") and planar > walk_speed + 0.5
	var target := 1.0 if sprinting else 0.0
	_sprint_factor = move_toward(_sprint_factor, target, fov_lerp_speed * delta)

	_camera.fov = lerpf(base_fov, sprint_fov, _sprint_factor)
	if _blur_mat:
		var cur: float = _blur_mat.get_shader_parameter("strength")
		_blur_mat.set_shader_parameter("strength",
			move_toward(cur, _sprint_factor, blur_lerp_speed * delta))


func _physics_process(delta: float) -> void:
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
		_air_jump = "run_jump" if planar > walk_speed + 0.5 else "jump"

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
	var target := dir * speed
	# Smoothly approach the target horizontal velocity (accel/decel feel).
	velocity.x = move_toward(velocity.x, target.x, acceleration * speed * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * speed * delta)

	move_and_slide()

	# Rotate the visual body to face the travel direction (GTA-style).
	if dir.length() > 0.1:
		var want_yaw := atan2(dir.x, dir.z)
		_body.rotation.y = lerp_angle(_body.rotation.y, want_yaw, rotation_speed * delta)

	_update_anim(dir, speed, is_on_floor())


## Pick the animation that matches the current motion and crossfade to it.
func _update_anim(dir: Vector3, speed: float, on_floor: bool) -> void:
	var clip := "idle"
	if not on_floor:
		clip = _air_jump   # "jump" or "run_jump", chosen at takeoff
	elif dir.length() > 0.1:
		clip = "run" if speed >= sprint_speed else "walk"
	_play(clip)


func _play(clip: String) -> void:
	if clip == _current_anim:
		return
	if not _anim.has_animation(clip):
		return
	_current_anim = clip
	# Longer blend time = smoother crossfades between locomotion states.
	_anim.play(clip, 0.25)
