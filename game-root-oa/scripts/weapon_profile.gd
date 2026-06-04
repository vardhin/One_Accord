@tool
class_name WeaponProfile
extends Resource
## One Accord — a weapon's animation + attachment data.
##
## This is the single source of truth that maps the player's COMBAT ACTIONS to
## the clip NAMES in player_anims.res, plus how the weapon mesh hangs off the
## hand. player.gd reads these at equip time and never hard-codes a clip name,
## so a new weapon (axe, staff, ...) or a re-skin is just a new .tres — no code
## edits. Clip names must match the canonical names produced by the import hook
## (see import/mixamo_anim_post_import.gd).
##
## A missing clip name (empty string, or a name not in the library) is handled
## gracefully by player.gd: that action's transition resolves instantly with no
## motion, exactly like before. So a half-authored weapon never soft-locks.

@export_group("Identity")
@export var display_name: String = "Sword"

@export_group("Attachment")
## Scene instanced and parented to the hand bone (the weapon mesh).
@export var weapon_scene: PackedScene
## Bone the weapon rides on. Mixamo rigs use the "mixamorig_" underscore prefix.
@export var hand_bone: String = "mixamorig_RightHand"
## Local grip offset/rotation in the hand (tune so the blade leaves the fist).
@export var grip_offset: Vector3 = Vector3(0.0, 0.04, 0.0)
@export var grip_rotation_deg: Vector3 = Vector3(-90.0, 0.0, 0.0)

@export_group("Action clips")
@export var unsheath: String = "sword_unsheath"   ## draw the weapon
@export var sheath: String = "sword_sheath"        ## put it away
## Light-attack chain, played in order as the player buffers follow-ups.
@export var light_combo: Array[String] = ["sword_light_1", "sword_light_2", "sword_light_3", "sword_light_4"]
@export var heavy: String = "sword_heavy"

@export_group("Armed locomotion")
## Played instead of the unarmed clips while the weapon is drawn (READY state).
## Leave any empty to fall back to the unarmed clip of the same role.
@export var armed_idle: String = "sword_idle"
@export var armed_walk: String = "sword_walk"
@export var armed_run: String = "sword_run"
@export var armed_jump: String = "sword_jump"
@export var armed_run_jump: String = "sword_run_jump"

@export_group("Feel")
## Crossfade time (s) when starting an action clip.
@export var action_blend: float = 0.12
## Crossfade time (s) between locomotion clips.
@export var locomotion_blend: float = 0.25
## Playback multiplier for attack/draw/sheath clips (>1 = faster). Mixamo swings
## are slow, so we speed them up.
@export var attack_speed_scale: float = 1.15

@export_group("Lunge")
## Forward speed (m/s) imparted at the START of each light hit. Parallel to
## light_combo by index; the clip lunges this fast, decaying over its length.
## A sprint into the attack carries the higher of (incoming speed, this).
@export var light_lunge: Array[float] = [3.5, 4.0, 5.0, 5.0]
## Forward speed (m/s) imparted by the heavy (jump) attack — the big leap.
@export var heavy_lunge: float = 8.0
## Fraction of the player's incoming planar speed added on TOP of the lunge when
## attacking out of a sprint (0 = no carry, 1 = full sprint speed added).
@export var sprint_carry: float = 0.6
## How quickly the lunge speed bleeds off across the attack (higher = snappier
## stop). The body coasts forward then settles.
@export var lunge_decay: float = 6.0


## Map an unarmed locomotion clip name to this weapon's armed variant, falling
## back to the unarmed name when the armed clip isn't configured.
func armed_variant(base: String) -> String:
	match base:
		"idle":     return armed_idle if armed_idle != "" else base
		"walk":     return armed_walk if armed_walk != "" else base
		"run":      return armed_run if armed_run != "" else base
		"jump":     return armed_jump if armed_jump != "" else base
		"run_jump": return armed_run_jump if armed_run_jump != "" else base
		_:          return base


## The light clip for a 1-based combo index, or "" if past the chain's end.
func light_clip(index_1based: int) -> String:
	var i := index_1based - 1
	if i >= 0 and i < light_combo.size():
		return light_combo[i]
	return ""


## Lunge speed (m/s) for a 1-based light combo index. Falls back to the last
## entry if light_lunge is shorter than the combo.
func light_lunge_speed(index_1based: int) -> float:
	if light_lunge.is_empty():
		return 0.0
	var i := clampi(index_1based - 1, 0, light_lunge.size() - 1)
	return light_lunge[i]


## Largest combo index this weapon supports (so player.gd doesn't hard-code 3).
func light_combo_len() -> int:
	return light_combo.size()
