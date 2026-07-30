extends Control

@onready var _led_board: LedBoard = %LedBoard
@onready var _text_panel: TextEditorPanel = %TextEditorPanel


func _ready() -> void:
	_text_panel.text_style = _led_board.text_style
	_text_panel.animation = _led_board.animation
	_text_panel.text_changed.connect(func(new_text: String) -> void: _led_board.text = new_text)
	_text_panel.play_requested.connect(_led_board.play)
	_text_panel.pause_requested.connect(_led_board.pause)
	_text_panel.stop_requested.connect(_led_board.stop)
