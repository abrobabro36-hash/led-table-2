class_name PresetDetailScreen
extends Control

const PATTERN_NAMES := {
	SignalPreset.BlinkPattern.SYNC: "Синхронно",
	SignalPreset.BlinkPattern.ALTERNATE: "Поочерёдно",
	SignalPreset.BlinkPattern.WIG_WAG: "Wig-Wag",
	SignalPreset.BlinkPattern.SOS_MORSE: "SOS (Морзе)",
}
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
@onready var _tab_row: HBoxContainer = %TabRow
@onready var _lights_tab_button: Button = %LightsTabButton
@onready var _siren_tab_button: Button = %SirenTabButton
@onready var _lights_section: VBoxContainer = %LightsSection
@onready var _style_row: HBoxContainer = %StyleRow
@onready var _speed_slider: HSlider = %SpeedSlider
@onready var _brightness_slider: HSlider = %BrightnessSlider
@onready var _siren_section: VBoxContainer = %SirenSection
@onready var _volume_row: HBoxContainer = %VolumeRow
@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _demo_button: Button = %DemoButton
@onready var _bottom_fullscreen_button: Button = %BottomFullscreenButton
@onready var _start_button: Button = %StartButton

var _preset: SignalPreset
var _working_preset: SignalPreset
var _selected_pattern: SignalPreset.BlinkPattern
var _is_active: bool = false
var _is_fullscreen: bool = false
var _margin_tween: Tween
var _demo_timer: Timer


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

	_back_button.pressed.connect(func() -> void: Router.pop())
	_favorite_button.pressed.connect(_on_favorite_pressed)
	_fullscreen_button.pressed.connect(_toggle_fullscreen)
	_bottom_fullscreen_button.pressed.connect(_toggle_fullscreen)
	_tap_area.gui_input.connect(_on_tap_area_gui_input)
	_lights_tab_button.pressed.connect(_show_lights_tab)
	_siren_tab_button.pressed.connect(_show_siren_tab)
	_speed_slider.value_changed.connect(func(value: float) -> void: _working_preset.blink_speed = value)
	_brightness_slider.value_changed.connect(func(value: float) -> void: _led_board.settings.brightness = value)
	_volume_slider.value_changed.connect(func(value: float) -> void: _led_board.set_siren_volume_db(linear_to_db(value)))
	_demo_button.pressed.connect(_on_demo_pressed)
	_start_button.pressed.connect(_on_start_pressed)

	_apply_preset()


func _apply_preset() -> void:
	if not _preset:
		return
	_working_preset = _preset.duplicate()
	_selected_pattern = _preset.default_pattern
	_title_label.text = _preset.display_name
	_favorite_button.text = "★" if AppSettings.is_favorite(_preset.id) else "☆"
	_speed_slider.set_value_no_signal(_working_preset.blink_speed)
	_brightness_slider.set_value_no_signal(_led_board.settings.brightness)
	_volume_slider.set_value_no_signal(0.8)
	_led_board.set_siren_volume_db(linear_to_db(0.8))

	_style_row.get_parent().visible = _preset.available_patterns.size() > 1
	for child in _style_row.get_children():
		child.queue_free()
	for pattern in _preset.available_patterns:
		var button := Button.new()
		button.text = PATTERN_NAMES.get(pattern, "?")
		button.toggle_mode = true
		button.button_pressed = pattern == _selected_pattern
		button.pressed.connect(_on_pattern_selected.bind(pattern, button))
		_style_row.add_child(button)

	var has_siren: bool = _preset.siren_type != SignalPreset.SirenType.NONE
	_tab_row.visible = has_siren
	_volume_row.visible = _preset.has_volume_control
	_show_lights_tab()


func _on_pattern_selected(pattern: SignalPreset.BlinkPattern, pressed_button: Button) -> void:
	_selected_pattern = pattern
	for button in _style_row.get_children():
		button.button_pressed = button == pressed_button
	if _is_active:
		_led_board.activate_preset(_working_preset, _selected_pattern)


func _show_lights_tab() -> void:
	_lights_tab_button.button_pressed = true
	_siren_tab_button.button_pressed = false
	_lights_section.visible = true
	_siren_section.visible = false


func _show_siren_tab() -> void:
	_lights_tab_button.button_pressed = false
	_siren_tab_button.button_pressed = true
	_lights_section.visible = false
	_siren_section.visible = true


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
	_led_board.activate_preset(_working_preset, _selected_pattern)
	_is_active = true
	_start_button.text = "Стоп"
	AppSettings.record_activation("signal", _preset.id)


func _deactivate() -> void:
	_demo_timer.stop()
	_led_board.deactivate_preset()
	_is_active = false
	_start_button.text = "Старт"


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
