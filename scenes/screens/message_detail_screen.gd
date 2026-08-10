class_name MessageDetailScreen
extends Control

const CURATED_MODES := [
	{"mode": AnimationSettings.Mode.TYPEWRITER, "label": "Печатание"},
	{"mode": AnimationSettings.Mode.BLINK, "label": "Мигание"},
	{"mode": AnimationSettings.Mode.SCROLL_HORIZONTAL, "label": "Скролл"},
	{"mode": AnimationSettings.Mode.PULSE, "label": "Пульсация"},
]
const FONT_NAMES := ["Inter", "Manrope", "Nunito Sans"]
const NORMAL_MARGIN := Vector4i(40, 32, 40, 16)
const FULLSCREEN_TWEEN_DURATION := 0.35
const DEMO_DURATION := 4.0

@onready var _led_board: LedBoard = %LedBoard
@onready var _tap_area: Control = %TapArea
@onready var _board_margin: MarginContainer = %BoardMargin
@onready var _panels_box: VBoxContainer = %PanelsBox
@onready var _back_button: Button = %BackButton
@onready var _title_label: Label = %TitleLabel
@onready var _favorite_button: Button = %FavoriteButton
@onready var _fullscreen_button: Button = %FullscreenButton
@onready var _text_input: LineEdit = %TextInput
@onready var _font_option: OptionButton = %FontOption
@onready var _text_color_swatch: ColorRect = %TextColorSwatch
@onready var _show_text_check: CheckButton = %ShowTextCheck
@onready var _style_row: HBoxContainer = %StyleRow
@onready var _speed_slider: HSlider = %SpeedSlider
@onready var _brightness_slider: HSlider = %BrightnessSlider
@onready var _demo_button: Button = %DemoButton
@onready var _bottom_fullscreen_button: Button = %BottomFullscreenButton
@onready var _start_button: Button = %StartButton
@onready var _color_picker: ColorPickerPanel = %ColorPickerPanel

var _preset: ThematicPreset
var _is_active: bool = false
var _is_fullscreen: bool = false
var _margin_tween: Tween
var _demo_timer: Timer
var _accent_box: StyleBoxFlat
var _accent_text_color: Color


func setup(data: Dictionary) -> void:
	_preset = data.get("preset")
	if is_node_ready():
		_apply_preset()


func _ready() -> void:
	_demo_timer = Timer.new()
	_demo_timer.one_shot = true
	_demo_timer.wait_time = DEMO_DURATION
	_demo_timer.timeout.connect(_on_demo_timeout)
	add_child(_demo_timer)

	for font_name in FONT_NAMES:
		_font_option.add_item(font_name)
	for entry in CURATED_MODES:
		var button := Button.new()
		button.text = entry.label
		button.toggle_mode = true
		button.pressed.connect(_on_mode_selected.bind(entry.mode))
		_style_row.add_child(button)

	_back_button.pressed.connect(func() -> void: Router.pop())
	_favorite_button.pressed.connect(_on_favorite_pressed)
	_fullscreen_button.pressed.connect(_toggle_fullscreen)
	_bottom_fullscreen_button.pressed.connect(_toggle_fullscreen)
	_tap_area.gui_input.connect(_on_tap_area_gui_input)
	_text_input.text_changed.connect(func(new_text: String) -> void: _led_board.text = new_text)
	_font_option.item_selected.connect(func(index: int) -> void: _led_board.text_style.font_choice = index)
	_text_color_swatch.gui_input.connect(_on_text_color_swatch_input)
	_show_text_check.toggled.connect(_led_board.set_presets_show_text)
	_speed_slider.value_changed.connect(func(value: float) -> void: _led_board.animation.speed = value)
	_brightness_slider.value_changed.connect(func(value: float) -> void: _led_board.settings.brightness = value)
	_demo_button.pressed.connect(_on_demo_pressed)
	_start_button.pressed.connect(_on_start_pressed)

	_apply_preset()


func _apply_preset() -> void:
	if not _preset:
		return
	_title_label.text = _preset.display_name
	_favorite_button.text = "★" if AppSettings.is_favorite(_preset.id) else "☆"
	_text_input.text = _led_board.text
	_font_option.select(_led_board.text_style.font_choice)
	_text_color_swatch.color = _led_board.settings.text_color
	_show_text_check.set_pressed_no_signal(_led_board.get_presets_show_text())
	_speed_slider.set_value_no_signal(_led_board.animation.speed)
	_brightness_slider.set_value_no_signal(_led_board.settings.brightness)
	_set_selected_mode(_led_board.animation.mode)

	var accent: Color = _preset.palette.colors[0] if _preset.palette and _preset.palette.colors.size() > 0 else Color.WHITE
	_accent_box = AccentTheme.build_stylebox(_start_button.get_theme_stylebox("pressed"), accent)
	_accent_text_color = AccentTheme.readable_text_color(accent)
	for child in _style_row.get_children():
		AccentTheme.tint_toggle_button(child, _accent_box, _accent_text_color)


func _set_selected_mode(mode: AnimationSettings.Mode) -> void:
	for i in _style_row.get_child_count():
		var button: Button = _style_row.get_child(i)
		button.button_pressed = CURATED_MODES[i].mode == mode


func _on_mode_selected(mode: AnimationSettings.Mode) -> void:
	_led_board.animation.mode = mode
	_set_selected_mode(mode)


func _on_text_color_swatch_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if _color_picker.color_picked.is_connected(_on_text_color_picked):
			_color_picker.color_picked.disconnect(_on_text_color_picked)
		_color_picker.color_picked.connect(_on_text_color_picked)
		_color_picker.open_for(_led_board.settings.text_color)


func _on_text_color_picked(color: Color) -> void:
	_text_color_swatch.color = color
	_led_board.settings.text_color = color


func _on_favorite_pressed() -> void:
	AppSettings.toggle_favorite(_preset.id)
	_favorite_button.text = "★" if AppSettings.is_favorite(_preset.id) else "☆"


func _on_demo_pressed() -> void:
	if not _is_active:
		_activate()
	_demo_timer.start()


func _on_demo_timeout() -> void:
	_deactivate()


func _on_start_pressed() -> void:
	if _is_active:
		_deactivate()
	else:
		_demo_timer.stop()
		_activate()


func _activate() -> void:
	_led_board.activate_thematic_preset(_preset)
	_is_active = true
	_start_button.text = "Стоп"
	AccentTheme.tint_active_button(_start_button, _accent_box, _accent_text_color, true)
	AppSettings.record_activation("thematic", _preset.id)


func _deactivate() -> void:
	_demo_timer.stop()
	_led_board.deactivate_thematic_preset()
	_is_active = false
	_start_button.text = "Старт"
	AccentTheme.tint_active_button(_start_button, _accent_box, _accent_text_color, false)


func _on_tap_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.double_click:
		_toggle_fullscreen()


func _toggle_fullscreen() -> void:
	if _is_fullscreen:
		_exit_fullscreen()
	else:
		_enter_fullscreen()


func _enter_fullscreen() -> void:
	_is_fullscreen = true
	_fade_panels(0.0, false)
	_animate_board_margin(0, 0, 0, 0)


func _exit_fullscreen() -> void:
	_is_fullscreen = false
	_fade_panels(1.0, true)
	_animate_board_margin(NORMAL_MARGIN.x, NORMAL_MARGIN.y, NORMAL_MARGIN.z, NORMAL_MARGIN.w)


func _fade_panels(target_alpha: float, visible_now: bool) -> void:
	if visible_now:
		_panels_box.get_parent().visible = true
	var tween := create_tween()
	tween.tween_property(_panels_box.get_parent(), "modulate:a", target_alpha, FULLSCREEN_TWEEN_DURATION)
	if not visible_now:
		tween.tween_callback(func() -> void: _panels_box.get_parent().visible = false)


func _animate_board_margin(left: int, top: int, right: int, bottom: int) -> void:
	if _margin_tween:
		_margin_tween.kill()
	_margin_tween = create_tween()
	_margin_tween.set_parallel(true)
	_margin_tween.set_trans(Tween.TRANS_SINE)
	_margin_tween.set_ease(Tween.EASE_OUT)
	_margin_tween.tween_property(_board_margin, "theme_override_constants/margin_left", left, FULLSCREEN_TWEEN_DURATION)
	_margin_tween.tween_property(_board_margin, "theme_override_constants/margin_top", top, FULLSCREEN_TWEEN_DURATION)
	_margin_tween.tween_property(_board_margin, "theme_override_constants/margin_right", right, FULLSCREEN_TWEEN_DURATION)
	_margin_tween.tween_property(_board_margin, "theme_override_constants/margin_bottom", bottom, FULLSCREEN_TWEEN_DURATION)
