class_name TextEditorPanel
extends PanelContainer

signal text_changed(new_text: String)
signal play_requested
signal pause_requested
signal stop_requested

const FONT_NAMES := ["Inter", "Manrope", "Nunito Sans"]
const MODE_NAMES := ["Статично", "Скролл ↔", "Скролл ↕", "Мигание", "Печатание", "Пульсация", "Волна", "Bounce"]

@export var text_style: TextStyle = preload("res://resources/default_text_style.tres")
@export var animation: AnimationSettings = preload("res://resources/default_animation_settings.tres")

@onready var _text_input: LineEdit = %TextInput
@onready var _font_option: OptionButton = %FontOption
@onready var _bold_check: CheckButton = %BoldCheck
@onready var _italic_check: CheckButton = %ItalicCheck
@onready var _letter_spacing_slider: HSlider = %LetterSpacingSlider
@onready var _scale_slider: HSlider = %ScaleSlider
@onready var _mode_option: OptionButton = %ModeOption
@onready var _reverse_check: CheckButton = %ReverseCheck
@onready var _speed_slider: HSlider = %SpeedSlider
@onready var _play_button: Button = %PlayButton
@onready var _pause_button: Button = %PauseButton
@onready var _stop_button: Button = %StopButton


func _ready() -> void:
	for font_name in FONT_NAMES:
		_font_option.add_item(font_name)
	for mode_name in MODE_NAMES:
		_mode_option.add_item(mode_name)

	_text_input.text = "LED Display 🎉"
	_font_option.select(text_style.font_choice)
	_bold_check.button_pressed = text_style.bold
	_italic_check.button_pressed = text_style.italic
	_letter_spacing_slider.value = text_style.letter_spacing
	_scale_slider.value = text_style.text_scale
	_mode_option.select(animation.mode)
	_reverse_check.button_pressed = animation.scroll_reverse
	_speed_slider.value = animation.speed

	_text_input.text_changed.connect(func(new_text: String) -> void: text_changed.emit(new_text))
	_font_option.item_selected.connect(func(index: int) -> void: text_style.font_choice = index)
	_bold_check.toggled.connect(func(pressed: bool) -> void: text_style.bold = pressed)
	_italic_check.toggled.connect(func(pressed: bool) -> void: text_style.italic = pressed)
	_letter_spacing_slider.value_changed.connect(func(value: float) -> void: text_style.letter_spacing = value)
	_scale_slider.value_changed.connect(func(value: float) -> void: text_style.text_scale = value)
	_mode_option.item_selected.connect(func(index: int) -> void: animation.mode = index)
	_reverse_check.toggled.connect(func(pressed: bool) -> void: animation.scroll_reverse = pressed)
	_speed_slider.value_changed.connect(func(value: float) -> void: animation.speed = value)

	_play_button.pressed.connect(func() -> void: play_requested.emit())
	_pause_button.pressed.connect(func() -> void: pause_requested.emit())
	_stop_button.pressed.connect(func() -> void: stop_requested.emit())

	text_changed.emit(_text_input.text)
