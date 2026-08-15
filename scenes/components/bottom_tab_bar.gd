class_name BottomTabBar
extends PanelContainer

signal tab_selected(index: int)

@onready var _buttons: Array[Button] = [%HomeButton, %FavoritesButton, %HistoryButton, %SettingsButton]
@onready var _pills: Array[PanelContainer] = [%HomePill, %FavoritesPill, %HistoryPill, %SettingsPill]
@onready var _labels: Array[Label] = [
	%HomePill.get_node("Label") as Label,
	%FavoritesPill.get_node("Label") as Label,
	%HistoryPill.get_node("Label") as Label,
	%SettingsPill.get_node("Label") as Label,
]

var _inactive_pill: StyleBoxFlat
var _active_pill: StyleBoxFlat


func _ready() -> void:
	_apply_compact_navigation_style()
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_button_pressed.bind(i))
	set_active(0)


func set_active(index: int) -> void:
	for i in _buttons.size():
		_buttons[i].button_pressed = i == index
		_pills[i].add_theme_stylebox_override("panel", _active_pill if i == index else _inactive_pill)
		_labels[i].add_theme_color_override(
			"font_color", Color(0.9, 0.94, 1, 1) if i == index else Color(0.5, 0.57, 0.67, 1)
		)


func _on_button_pressed(index: int) -> void:
	set_active(index)
	tab_selected.emit(index)


func _apply_compact_navigation_style() -> void:
	var shell := StyleBoxFlat.new()
	# The bar must visually separate scrolling Home content while staying
	# quieter than the per-mode card accents.
	shell.bg_color = Color(0.018, 0.027, 0.039, 1)
	shell.border_width_top = 1
	shell.border_color = Color(0.18, 0.24, 0.32, 0.9)
	shell.corner_radius_top_left = 18
	shell.corner_radius_top_right = 18
	add_theme_stylebox_override("panel", shell)

	var transparent_button := StyleBoxFlat.new()
	transparent_button.bg_color = Color(0, 0, 0, 0)
	_inactive_pill = StyleBoxFlat.new()
	_inactive_pill.bg_color = Color(0, 0, 0, 0)
	_inactive_pill.corner_radius_top_left = 16
	_inactive_pill.corner_radius_top_right = 16
	_inactive_pill.corner_radius_bottom_right = 16
	_inactive_pill.corner_radius_bottom_left = 16
	_active_pill = _inactive_pill.duplicate()
	_active_pill.bg_color = Color(0.18, 0.28, 0.5, 0.62)
	_active_pill.border_width_top = 1
	_active_pill.border_width_bottom = 1
	_active_pill.border_color = Color(0.52, 0.67, 0.98, 0.48)
	for button in _buttons:
		button.add_theme_stylebox_override("normal", transparent_button)
		button.add_theme_stylebox_override("hover", transparent_button)
		button.add_theme_stylebox_override("pressed", transparent_button)
