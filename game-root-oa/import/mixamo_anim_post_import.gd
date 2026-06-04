@tool
extends EditorScenePostImport
## One Accord — Mixamo animation post-import hook.
##
## Runs automatically when any FBX wired to this script (via import_script/path
## in its .import) finishes importing. For a Mixamo single-clip FBX it:
##   1. Reads the SOURCE filename stem (e.g. "sword_and_shield_slash_2").
##   2. Looks it up in CLIP_MAP -> a canonical clip name the game uses
##      ("sword_light_2") plus a loop flag.
##   3. Renames the single imported Animation to that canonical name and sets its
##      loop_mode (LINEAR for idle/locomotion, NONE for one-shot attacks/draws).
##
## Files with no CLIP_MAP entry still import fine: the clip keeps a sanitized
## version of its filename stem and defaults to no-loop. So "everything comes in"
## — adding a new clip later is one line in CLIP_MAP (or zero, if the auto-name
## is good enough).
##
## This is the ONLY place clip names + loop decisions live for the import side.
## The runtime never sees filenames — it asks a WeaponProfile for clip names,
## which must match the canonical names produced here.

# canonical name -> should it loop? (true = LINEAR, false = NONE)
# filename stem (lowercase, no .fbx) -> canonical clip name
const CLIP_MAP := {
	# --- base (unarmed) locomotion: names player.gd already expects ---
	"breathing_idle":                "idle",
	"standard_walk":                 "walk",
	"start_walking":                 "walk_start",
	"running":                       "run",
	"jump":                          "jump",
	"running_jump":                  "run_jump",

	# --- core combat (wired in v0) ---
	"sheath_sword_2":                "sword_unsheath",   # draw
	"sheath_sword_1":                "sword_sheath",     # put away
	"sword_and_shield_slash":        "sword_light_1",
	"sword_and_shield_slash_2":      "sword_light_2",
	"sword_and_shield_slash_3":      "sword_light_3",
	"sword_and_shield_slash_4":      "sword_light_4",    # spare combo extension
	"sword_and_shield_slash_5":      "sword_light_5",
	"sword_and_shield_attack":       "sword_heavy",
	"sword_and_shield_attack_2":     "sword_heavy_2",
	"sword_and_shield_attack_3":     "sword_heavy_3",
	"sword_and_shield_attack_4":     "sword_heavy_4",

	# --- armed locomotion ---
	"sword_and_shield_idle":         "sword_idle",
	"sword_and_shield_idle_2":       "sword_idle_2",
	"sword_and_shield_idle_3":       "sword_idle_3",
	"sword_and_shield_idle_4":       "sword_idle_4",
	"sword_and_shield_walk":         "sword_walk",
	"sword_and_shield_walk_2":       "sword_walk_2",
	"sword_and_shield_run":          "sword_run",
	"sword_and_shield_run_2":        "sword_run_2",
	"sword_and_shield_strafe":       "sword_strafe_l",
	"sword_and_shield_strafe_2":     "sword_strafe_r",
	"sword_and_shield_strafe_3":     "sword_strafe_3",
	"sword_and_shield_strafe_4":     "sword_strafe_4",
	"sword_and_shield_turn":         "sword_turn_l",
	"sword_and_shield_turn_2":       "sword_turn_r",
	"sword_and_shield_180_turn":     "sword_turn_180",
	"sword_and_shield_180_turn_2":   "sword_turn_180_2",
	"sword_and_shield_jump":         "sword_jump",
	"sword_and_shield_jump_2":       "sword_run_jump",

	# --- crouch set ---
	"sword_and_shield_crouch":           "sword_crouch",
	"sword_and_shield_crouch_idle":      "sword_crouch_idle",
	"sword_and_shield_crouching":        "sword_crouch_walk",
	"sword_and_shield_crouching_2":      "sword_crouch_walk_2",
	"sword_and_shield_crouching_3":      "sword_crouch_walk_3",
	"sword_and_shield_crouch_block":     "sword_crouch_block",
	"sword_and_shield_crouch_block_2":   "sword_crouch_block_2",
	"sword_and_shield_crouch_block_idle":"sword_crouch_block_idle",

	# --- defense / reactions ---
	"sword_and_shield_block":        "sword_block",
	"sword_and_shield_block_2":      "sword_block_2",
	"sword_and_shield_block_idle":   "sword_block_idle",
	"sword_and_shield_impact":       "sword_impact_1",
	"sword_and_shield_impact_2":     "sword_impact_2",
	"sword_and_shield_impact_3":     "sword_impact_3",
	"sword_and_shield_death":        "sword_death_1",
	"sword_and_shield_death_2":      "sword_death_2",
	"sword_and_shield_kick":         "sword_kick",

	# --- spell-friendly names for the future magic system ---
	"sword_and_shield_casting":      "spell_cast",
	"sword_and_shield_casting_2":    "spell_cast_2",
	"sword_and_shield_power_up":     "spell_power_up",
}

# Canonical names that should LOOP (LINEAR). Everything else = one-shot (NONE).
const LOOPING := {
	"idle": true, "walk": true, "run": true,
	"sword_idle": true, "sword_idle_2": true, "sword_idle_3": true, "sword_idle_4": true,
	"sword_walk": true, "sword_walk_2": true,
	"sword_run": true, "sword_run_2": true,
	"sword_strafe_l": true, "sword_strafe_r": true, "sword_strafe_3": true, "sword_strafe_4": true,
	"sword_block_idle": true,
	"sword_crouch_idle": true, "sword_crouch_walk": true, "sword_crouch_walk_2": true,
	"sword_crouch_walk_3": true, "sword_crouch_block_idle": true,
}


func _post_import(scene: Node) -> Object:
	var ap := _find_anim_player(scene)
	if ap == null:
		return scene

	var stem := _source_stem()
	var canonical: String = CLIP_MAP.get(stem, _sanitize(stem))

	# A freshly-imported Mixamo FBX has exactly one (default-library) animation.
	var lib_names := ap.get_animation_library_list()
	for lib_name in lib_names:
		var lib := ap.get_animation_library(lib_name)
		var anims := lib.get_animation_list()
		# Single clip per Mixamo file; rename the first to canonical.
		if anims.size() == 1:
			var old: StringName = anims[0]
			var anim := lib.get_animation(old)
			anim.loop_mode = Animation.LOOP_LINEAR if LOOPING.get(canonical, false) else Animation.LOOP_NONE
			if String(old) != canonical:
				lib.remove_animation(old)
				lib.add_animation(canonical, anim)
		else:
			# Defensive: more than one clip — apply loop flag, leave names alone.
			for n in anims:
				var a := lib.get_animation(n)
				a.loop_mode = Animation.LOOP_LINEAR if LOOPING.get(String(n), false) else Animation.LOOP_NONE

	return scene


## Source filename stem, lowercased, without extension.
func _source_stem() -> String:
	var src := get_source_file()  # e.g. res://.../sword_and_shield_slash_2.fbx
	return src.get_file().get_basename().to_lower()


## Turn an arbitrary filename into a safe clip name (fallback for unmapped files).
func _sanitize(s: String) -> String:
	var out := ""
	for ch in s.to_lower():
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") or ch == "_":
			out += ch
		else:
			out += "_"
	return out


## NOTE: horizontal "in-place" travel stripping lives in build_anim_library.gd,
## not here — post-import position tracks are compressed and track_set_key_value
## silently no-ops on them. The build script operates on uncompressed duplicates.


func _find_anim_player(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n
	for c in n.get_children():
		var f := _find_anim_player(c)
		if f:
			return f
	return null
