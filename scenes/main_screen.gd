extends Control

const NORMAL_MARGIN_LEFT := 40
const NORMAL_MARGIN_TOP := 64
const NORMAL_MARGIN_RIGHT := 40
const NORMAL_MARGIN_BOTTOM := 16
const FULLSCREEN_TWEEN_DURATION := 0.35
const BANNER_FADE_DURATION := 0.2

@onready var _led_board: LedBoard = %LedBoard
@onready var _text_panel: TextEditorPanel = %TextEditorPanel
@onready var _background_panel: BackgroundPanel = %BackgroundPanel
@onready var _color_picker: ColorPickerPanel = %ColorPickerPanel
@onready var _tap_area: Control = %TapArea
@onready var _board_margin: MarginContainer = %BoardMargin
@onready var _panel_scroll: ScrollContainer = $Layout/PanelScroll
@onready var _ad_banner: PanelContainer = %AdBanner

var _is_fullscreen: bool = false
var _margin_tween: Tween
var _banner_tween: Tween


func _ready() -> void:
	_text_panel.text_style = _led_board.text_style
	_text_panel.animation = _led_board.animation
	_text_panel.led_settings = _led_board.settings
	_text_panel.color_picker = _color_picker
	_text_panel.text_changed.connect(func(new_text: String) -> void: _led_board.text = new_text)
	_text_panel.play_requested.connect(_led_board.play)
	_text_panel.pause_requested.connect(_led_board.pause)
	_text_panel.stop_requested.connect(_led_board.stop)

	_background_panel.background = _led_board.background
	_background_panel.color_picker = _color_picker

	_tap_area.gui_input.connect(_on_tap_area_gui_input)

	if not is_premium():
		_ad_banner.visible = true
		_ad_banner.modulate.a = 1.0


func is_premium() -> bool:
	return false


func show_banner() -> void:
	if is_premium():
		return
	if _banner_tween:
		_banner_tween.kill()
	_ad_banner.visible = true
	_banner_tween = create_tween()
	_banner_tween.tween_property(_ad_banner, "modulate:a", 1.0, BANNER_FADE_DURATION)


func hide_banner() -> void:
	if _banner_tween:
		_banner_tween.kill()
	_banner_tween = create_tween()
	_banner_tween.tween_property(_ad_banner, "modulate:a", 0.0, BANNER_FADE_DURATION)
	_banner_tween.tween_callback(func() -> void: _ad_banner.visible = false)


func _on_tap_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.double_click:
		if _is_fullscreen:
			_exit_fullscreen()
		else:
			_enter_fullscreen()


func _enter_fullscreen() -> void:
	_is_fullscreen = true
	hide_banner()
	_fade_out_panels()
	_animate_board_margin(0, 0, 0, 0)


func _exit_fullscreen() -> void:
	_is_fullscreen = false
	show_banner()
	_fade_in_panels()
	_animate_board_margin(NORMAL_MARGIN_LEFT, NORMAL_MARGIN_TOP, NORMAL_MARGIN_RIGHT, NORMAL_MARGIN_BOTTOM)


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


func _fade_out_panels() -> void:
	var tween := create_tween()
	tween.tween_property(_panel_scroll, "modulate:a", 0.0, FULLSCREEN_TWEEN_DURATION)
	tween.tween_callback(func() -> void: _panel_scroll.visible = false)


func _fade_in_panels() -> void:
	_panel_scroll.visible = true
	_panel_scroll.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_panel_scroll, "modulate:a", 1.0, FULLSCREEN_TWEEN_DURATION)
