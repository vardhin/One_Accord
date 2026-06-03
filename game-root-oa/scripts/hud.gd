extends CanvasLayer
## One Accord — minimal in-game HUD.
##
## Shows a controls cheat-sheet in the corner and owns two global hotkeys:
##   Y → toggle fullscreen
##   H → show/hide this controls panel
##
## Lives as a child of the world scene (see scenes/world.tscn).

@onready var _panel: Control = $Controls


func _ready() -> void:
	# Hotkeys here are UI-global, so process even while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		_toggle_fullscreen()
	elif event.is_action_pressed("toggle_help"):
		_panel.visible = not _panel.visible


func _toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
			or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
