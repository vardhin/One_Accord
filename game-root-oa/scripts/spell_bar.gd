extends Control
## One Accord — Dark-Souls-style spell bar.
##
## A row of slots, one per SpellProfile on the player, shown bottom-centre. The
## active slot (picked with 1/2/3) is highlighted with a glow + ring; the others
## sit dim. Each slot shows the spell's icon if it has one, else a coloured disc
## tinted by the spell's `color` (so even icon-less spells read distinctly).
##
## It self-populates from the player's `spells` array at startup and reacts to the
## player's selection through the `spell_bar` group: player.gd calls
## `set_active_spell(i)` on this group whenever 1/2/3 is pressed.

@export_group("Layout")
@export var slot_size: float = 64.0
@export var slot_gap: float = 10.0
@export var bottom_margin: float = 28.0

var _player: Node
var _spells: Array = []                 ## the player's SpellProfile array
var _active: int = 0
var _slots: Array = []                  ## [{panel:PanelContainer, ring:Panel, disc:ColorRect, num:Label}]


func _ready() -> void:
	add_to_group("spell_bar")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	# Resolve the player + its spells once the scene is up.
	call_deferred("_bind_player")


func _bind_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if _player == null:
		# Fall back: find a CharacterBody3D with a `spells` property.
		_player = _find_player(get_tree().current_scene)
	if _player and "spells" in _player:
		_spells = _player.spells
		_active = _player.active_spell if "active_spell" in _player else 0
	_build_slots()


func _find_player(n: Node) -> Node:
	if n == null:
		return null
	if n is CharacterBody3D and "spells" in n:
		return n
	for c in n.get_children():
		var f := _find_player(c)
		if f:
			return f
	return null


# ── Slot construction ──────────────────────────────────────────────────────
func _build_slots() -> void:
	for s in _slots:
		(s["panel"] as Node).queue_free()
	_slots.clear()
	if _spells.is_empty():
		return

	var n := _spells.size()
	var total_w := n * slot_size + (n - 1) * slot_gap
	var start_x := -total_w * 0.5            # centred via the bottom-wide anchor

	for i in n:
		var profile = _spells[i]
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(slot_size, slot_size)
		panel.position = Vector2(start_x + i * (slot_size + slot_gap), -slot_size - bottom_margin)
		panel.anchor_left = 0.5
		panel.anchor_right = 0.5
		panel.anchor_top = 1.0
		panel.anchor_bottom = 1.0
		panel.add_theme_stylebox_override("panel", _slot_style(false))
		add_child(panel)

		# Icon, or a coloured disc tinted by the spell color.
		var content := CenterContainer.new()
		panel.add_child(content)
		var icon_tex: Texture2D = profile.icon if profile and "icon" in profile else null
		var disc: Control
		if icon_tex:
			var tr := TextureRect.new()
			tr.texture = icon_tex
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.custom_minimum_size = Vector2(slot_size - 16, slot_size - 16)
			content.add_child(tr)
			disc = tr
		else:
			var rect := ColorRect.new()
			rect.color = (profile.color if profile and "color" in profile else Color.WHITE)
			rect.custom_minimum_size = Vector2(slot_size - 22, slot_size - 22)
			content.add_child(rect)
			disc = rect

		# Slot number (1/2/3) in the corner.
		var num := Label.new()
		num.text = str(i + 1)
		num.add_theme_color_override("font_color", Color.WHITE)
		num.add_theme_color_override("font_outline_color", Color.BLACK)
		num.add_theme_constant_override("outline_size", 4)
		num.position = Vector2(6, 2)
		panel.add_child(num)

		_slots.append({"panel": panel, "disc": disc, "num": num})

	_refresh_highlight()


## Two looks: a dim panel for inactive slots, a bright gold-ringed one for active.
func _slot_style(active: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.55)
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(2 if not active else 3)
	sb.border_color = Color(0.4, 0.45, 0.5, 0.7) if not active else Color(1.0, 0.82, 0.2, 1.0)
	if active:
		sb.shadow_color = Color(1.0, 0.8, 0.2, 0.6)
		sb.shadow_size = 10
	return sb


func _refresh_highlight() -> void:
	for i in _slots.size():
		var panel: PanelContainer = _slots[i]["panel"]
		var is_active := (i == _active)
		panel.add_theme_stylebox_override("panel", _slot_style(is_active))
		var disc: Control = _slots[i]["disc"]
		disc.modulate = Color(1, 1, 1, 1) if is_active else Color(1, 1, 1, 0.45)


# ── Called by player.gd via the "spell_bar" group on 1/2/3 ─────────────────
func set_active_spell(index: int) -> void:
	if index < 0 or index >= _slots.size():
		return
	_active = index
	_refresh_highlight()
