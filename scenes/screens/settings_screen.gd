class_name SettingsScreen
extends Control

const PACKAGE_NAME := "com.example.leddisplay"
const APP_VERSION := "1.0"
const SHARE_TEXT := "Попробуй LED Display — симулятор светодиодного табло для Android!"

const LED_DENSITY_PRESETS := {
	"low": {"dot_size": 5.0, "dot_spacing": 16.0},
	"medium": {"dot_size": 3.5, "dot_spacing": 10.0},
	"high": {"dot_size": 2.5, "dot_spacing": 7.0},
}
const THEME_PRESETS := {
	"dark": {"mode": BackgroundSettings.Mode.SOLID, "color": Color(0.05, 0.05, 0.06)},
	"darker": {"mode": BackgroundSettings.Mode.SOLID, "color": Color(0.02, 0.02, 0.025)},
	"pure_black": {"mode": BackgroundSettings.Mode.TRUE_BLACK, "color": Color(0.05, 0.05, 0.06)},
}

@onready var _auto_start_check: CheckButton = %AutoStartCheck
@onready var _keep_screen_on_check: CheckButton = %KeepScreenOnCheck
@onready var _vibration_check: CheckButton = %VibrationCheck
@onready var _led_grid_check: CheckButton = %LedGridCheck
@onready var _density_low_button: Button = %DensityLowButton
@onready var _density_medium_button: Button = %DensityMediumButton
@onready var _density_high_button: Button = %DensityHighButton
@onready var _theme_dark_button: Button = %ThemeDarkButton
@onready var _theme_darker_button: Button = %ThemeDarkerButton
@onready var _theme_pure_black_button: Button = %ThemePureBlackButton
@onready var _rate_button: Button = %RateButton
@onready var _share_button: Button = %ShareButton
@onready var _share_status_label: Label = %ShareStatusLabel
@onready var _version_label: Label = %VersionLabel

var _led_settings: LedSettings = preload("res://resources/default_led_settings.tres")
var _background_settings: BackgroundSettings = preload("res://resources/default_background_settings.tres")


func _ready() -> void:
	var data := AppSettings.data
	_auto_start_check.set_pressed_no_signal(data.auto_start_last_mode)
	_keep_screen_on_check.set_pressed_no_signal(data.keep_screen_on)
	_vibration_check.set_pressed_no_signal(data.vibration_enabled)
	_led_grid_check.set_pressed_no_signal(_led_settings.mask_enabled)
	_update_density_buttons(data.led_density)
	_update_theme_buttons(data.theme_variant)
	_version_label.text = "Версия %s" % APP_VERSION

	_auto_start_check.toggled.connect(AppSettings.set_auto_start_last_mode)
	_keep_screen_on_check.toggled.connect(AppSettings.set_keep_screen_on)
	_vibration_check.toggled.connect(AppSettings.set_vibration_enabled)
	_led_grid_check.toggled.connect(func(enabled: bool) -> void: _led_settings.mask_enabled = enabled)

	_density_low_button.pressed.connect(_apply_density.bind("low"))
	_density_medium_button.pressed.connect(_apply_density.bind("medium"))
	_density_high_button.pressed.connect(_apply_density.bind("high"))

	_theme_dark_button.pressed.connect(_apply_theme.bind("dark"))
	_theme_darker_button.pressed.connect(_apply_theme.bind("darker"))
	_theme_pure_black_button.pressed.connect(_apply_theme.bind("pure_black"))

	_rate_button.pressed.connect(_on_rate_pressed)
	_share_button.pressed.connect(_on_share_pressed)


func _apply_density(variant: String) -> void:
	var preset: Dictionary = LED_DENSITY_PRESETS[variant]
	_led_settings.dot_size = preset.dot_size
	_led_settings.dot_spacing = preset.dot_spacing
	AppSettings.set_led_density(variant)
	_update_density_buttons(variant)


func _apply_theme(variant: String) -> void:
	var preset: Dictionary = THEME_PRESETS[variant]
	_background_settings.mode = preset.mode
	_background_settings.solid_color = preset.color
	AppSettings.set_theme_variant(variant)
	_update_theme_buttons(variant)


func _update_density_buttons(variant: String) -> void:
	_density_low_button.button_pressed = variant == "low"
	_density_medium_button.button_pressed = variant == "medium"
	_density_high_button.button_pressed = variant == "high"


func _update_theme_buttons(variant: String) -> void:
	_theme_dark_button.button_pressed = variant == "dark"
	_theme_darker_button.button_pressed = variant == "darker"
	_theme_pure_black_button.button_pressed = variant == "pure_black"


func _on_rate_pressed() -> void:
	OS.shell_open("market://details?id=%s" % PACKAGE_NAME)


func _on_share_pressed() -> void:
	DisplayServer.clipboard_set(SHARE_TEXT)
	_share_status_label.text = "Текст скопирован в буфер обмена"
