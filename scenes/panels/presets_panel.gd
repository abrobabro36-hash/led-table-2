class_name PresetsPanel
extends PanelContainer

signal preset_selected(preset: SignalPreset, pattern: SignalPreset.BlinkPattern)
signal pattern_changed(pattern: SignalPreset.BlinkPattern)
signal volume_changed(volume_db: float)
signal stop_requested

const PRESET_PATHS := [
	"res://resources/presets/police.tres",
	"res://resources/presets/ambulance.tres",
	"res://resources/presets/firetruck.tres",
	"res://resources/presets/warning.tres",
	"res://resources/presets/sos.tres",
	"res://resources/presets/taxi.tres",
	"res://resources/presets/security.tres",
]
const PATTERN_NAMES := {
	SignalPreset.BlinkPattern.SYNC: "Синхронно",
	SignalPreset.BlinkPattern.ALTERNATE: "Поочерёдно",
	SignalPreset.BlinkPattern.WIG_WAG: "Wig-Wag",
	SignalPreset.BlinkPattern.SOS_MORSE: "SOS (Морзе)",
}

@onready var _preset_grid: GridContainer = %PresetGrid
@onready var _pattern_row: HBoxContainer = %PatternRow
@onready var _pattern_option: OptionButton = %PatternOption
@onready var _volume_row: HBoxContainer = %VolumeRow
@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _stop_button: Button = %StopButton
@onready var _radio_box: VBoxContainer = %RadioBox
@onready var _radio_record_button: Button = %RadioRecordButton
@onready var _radio_play_button: Button = %RadioPlayButton
@onready var _radio_repeat_check: CheckButton = %RadioRepeatCheck


func _ready() -> void:
	for path in PRESET_PATHS:
		var preset: SignalPreset = load(path)
		var button := Button.new()
		button.text = preset.display_name
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.pressed.connect(_on_preset_pressed.bind(preset))
		_preset_grid.add_child(button)

	_pattern_row.visible = false
	_volume_row.visible = false
	_radio_box.visible = false

	_pattern_option.item_selected.connect(_on_pattern_item_selected)
	_volume_slider.value_changed.connect(func(value: float) -> void: volume_changed.emit(linear_to_db(value)))
	_stop_button.pressed.connect(func() -> void: stop_requested.emit())

	_radio_record_button.pressed.connect(_on_radio_record_pressed)
	_radio_play_button.pressed.connect(_on_radio_play_pressed)
	_radio_repeat_check.toggled.connect(AudioManager.set_repeat)
	AudioManager.recording_state_changed.connect(_on_radio_recording_state_changed)
	AudioManager.playback_state_changed.connect(_on_radio_playback_state_changed)


func _on_preset_pressed(preset: SignalPreset) -> void:
	_pattern_row.visible = preset.available_patterns.size() > 1
	if _pattern_row.visible:
		_pattern_option.clear()
		var default_index := 0
		for i in preset.available_patterns.size():
			var pattern: SignalPreset.BlinkPattern = preset.available_patterns[i]
			_pattern_option.add_item(PATTERN_NAMES.get(pattern, "?"))
			_pattern_option.set_item_metadata(i, pattern)
			if pattern == preset.default_pattern:
				default_index = i
		_pattern_option.select(default_index)
	_volume_row.visible = preset.has_volume_control
	if preset.has_volume_control:
		_volume_slider.value = 0.8
	_radio_box.visible = preset.id == "police"
	if _radio_box.visible:
		_radio_play_button.disabled = not AudioManager.can_play_recording()
	preset_selected.emit(preset, preset.default_pattern)


func _on_radio_record_pressed() -> void:
	if AudioManager.is_recording:
		AudioManager.stop_recording()
	else:
		AudioManager.start_recording()


func _on_radio_play_pressed() -> void:
	if AudioManager.is_playing:
		AudioManager.stop_playback()
	else:
		AudioManager.play_recording()


func _on_radio_recording_state_changed(recording: bool) -> void:
	_radio_record_button.text = "Стоп запись" if recording else "Запись"
	_radio_play_button.disabled = not AudioManager.can_play_recording()


func _on_radio_playback_state_changed(playing: bool) -> void:
	_radio_play_button.text = "Стоп" if playing else "Воспроизвести"


func _on_pattern_item_selected(index: int) -> void:
	pattern_changed.emit(_pattern_option.get_item_metadata(index))
