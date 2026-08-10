class_name RecorderPanel
extends PanelContainer

@onready var _record_button: Button = %RecordButton
@onready var _play_button: Button = %PlayButton
@onready var _repeat_check: CheckButton = %RepeatCheck
@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_record_button.pressed.connect(_on_record_pressed)
	_play_button.pressed.connect(_on_play_pressed)
	_repeat_check.toggled.connect(AudioManager.set_repeat)
	_volume_slider.value_changed.connect(func(value: float) -> void: AudioManager.set_playback_volume_db(linear_to_db(value)))
	AudioManager.recording_state_changed.connect(_on_recording_state_changed)
	AudioManager.playback_state_changed.connect(_on_playback_state_changed)
	_update_play_button()


func _on_record_pressed() -> void:
	if AudioManager.is_recording:
		AudioManager.stop_recording()
	else:
		AudioManager.start_recording()


func _on_play_pressed() -> void:
	if AudioManager.is_playing:
		AudioManager.stop_playback()
	else:
		AudioManager.play_recording()


func _on_recording_state_changed(recording: bool) -> void:
	_record_button.text = "Стоп запись" if recording else "Запись"
	_status_label.text = "Идёт запись…" if recording else ""
	_update_play_button()


func _on_playback_state_changed(playing: bool) -> void:
	_play_button.text = "Стоп" if playing else "Воспроизвести"


func _update_play_button() -> void:
	_play_button.disabled = not AudioManager.can_play_recording()
