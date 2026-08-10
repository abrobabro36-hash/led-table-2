class_name TextEditorPanel
extends PanelContainer

signal text_changed(new_text: String)
signal play_requested
signal pause_requested
signal stop_requested
signal show_text_in_presets_toggled(enabled: bool)

const FONT_NAMES := ["Inter", "Manrope", "Nunito Sans"]
const MODE_NAMES := ["Статично", "Скролл ↔", "Скролл ↕", "Мигание", "Печатание", "Пульсация", "Волна", "Bounce"]

@export var text_style: TextStyle = preload("res://resources/default_text_style.tres")
@export var animation: AnimationSettings = preload("res://resources/default_animation_settings.tres")
@export var led_settings: LedSettings = preload("res://resources/default_led_settings.tres")
@export var color_picker: ColorPickerPanel

@onready var _text_input: LineEdit = %TextInput
@onready var _font_option: OptionButton = %FontOption
@onready var _bold_check: CheckButton = %BoldCheck
@onready var _italic_check: CheckButton = %ItalicCheck
@onready var _text_color_swatch: ColorRect = %TextColorSwatch
@onready var _letter_spacing_slider: HSlider = %LetterSpacingSlider
@onready var _scale_slider: HSlider = %ScaleSlider
@onready var _mode_option: OptionButton = %ModeOption
@onready var _reverse_check: CheckButton = %ReverseCheck
@onready var _speed_slider: HSlider = %SpeedSlider
@onready var _play_button: Button = %PlayButton
@onready var _pause_button: Button = %PauseButton
@onready var _stop_button: Button = %StopButton
@onready var _show_text_in_presets_check: CheckButton = %ShowTextInPresetsCheck


func _ready() -> void:
	for font_name in FONT_NAMES:
		_font_option.add_item(font_name)
	for mode_name in MODE_NAMES:
		_mode_option.add_item(mode_name)

	_text_input.text = "LED Display 🎉"
	sync_ui()

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

	_show_text_in_presets_check.button_pressed = true
	_show_text_in_presets_check.toggled.connect(func(pressed: bool) -> void: show_text_in_presets_toggled.emit(pressed))

	_text_color_swatch.gui_input.connect(_on_text_color_swatch_input)

	text_changed.emit(_text_input.text)
	show_text_in_presets_toggled.emit(true)


## Re-reads all widgets from text_style/animation/led_settings; call after
## their fields have been changed from outside (e.g. loading a project).
func sync_ui() -> void:
	_font_option.select(text_style.font_choice)
	_bold_check.set_pressed_no_signal(text_style.bold)
	_italic_check.set_pressed_no_signal(text_style.italic)
	_letter_spacing_slider.set_value_no_signal(text_style.letter_spacing)
	_scale_slider.set_value_no_signal(text_style.text_scale)
	_mode_option.select(animation.mode)
	_reverse_check.set_pressed_no_signal(animation.scroll_reverse)
	_speed_slider.set_value_no_signal(animation.speed)
	_text_color_swatch.color = led_settings.text_color


func set_text(value: String) -> void:
	_text_input.text = value


func _on_text_color_swatch_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if color_picker.color_picked.is_connected(_on_text_color_picked):
			color_picker.color_picked.disconnect(_on_text_color_picked)
		color_picker.color_picked.connect(_on_text_color_picked)
		color_picker.open_for(led_settings.text_color)


func _on_text_color_picked(color: Color) -> void:
	_text_color_swatch.color = color
	led_settings.text_color = color
