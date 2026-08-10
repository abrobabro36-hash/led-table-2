class_name BottomTabBar
extends PanelContainer

signal tab_selected(index: int)

@onready var _buttons: Array[Button] = [%HomeButton, %FavoritesButton, %HistoryButton, %SettingsButton]


func _ready() -> void:
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_button_pressed.bind(i))
	set_active(0)


func set_active(index: int) -> void:
	for i in _buttons.size():
		_buttons[i].button_pressed = i == index


func _on_button_pressed(index: int) -> void:
	set_active(index)
	tab_selected.emit(index)
