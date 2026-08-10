extends Node

signal recording_state_changed(is_recording: bool)
signal playback_state_changed(is_playing: bool)

const RECORD_BUS := "RadioRecord"
const PLAYBACK_BUS := "RadioPlayback"
const SAVE_PATH := "user://radio_recording.wav"
const RECORD_AUDIO_PERMISSION := "android.permission.RECORD_AUDIO"

var is_recording: bool = false
var is_playing: bool = false
var has_recording: bool = false
var repeat_playback: bool = false

var _mic_player: AudioStreamPlayer
var _record_effect: AudioEffectRecord
var _playback_player: AudioStreamPlayer
var _last_recording: AudioStreamWAV


func _ready() -> void:
	_ensure_record_bus()
	_ensure_playback_bus()
	_playback_player = AudioStreamPlayer.new()
	_playback_player.bus = PLAYBACK_BUS
	add_child(_playback_player)
	_playback_player.finished.connect(_on_playback_finished)
	has_recording = FileAccess.file_exists(SAVE_PATH)


## Whether there's a recording actually loaded in memory and ready to play.
## `has_recording` alone can be true from a previous session's saved file
## even though it hasn't been read back into memory yet (no runtime WAV
## loader for arbitrary user:// paths in Godot — see plan notes).
func can_play_recording() -> bool:
	return _last_recording != null


func has_permission() -> bool:
	if OS.get_name() != "Android":
		return true
	return RECORD_AUDIO_PERMISSION in OS.get_granted_permissions()


func start_recording() -> void:
	if is_recording:
		return
	if not has_permission():
		if OS.get_name() == "Android":
			OS.request_permissions()
		return
	call_deferred("_do_start_recording")


func stop_recording() -> void:
	if not is_recording:
		return
	_record_effect.set_recording_active(false)
	if _mic_player:
		_mic_player.stop()
	is_recording = false
	var recording: AudioStreamWAV = _record_effect.get_recording()
	if recording:
		_last_recording = recording
		recording.save_to_wav(SAVE_PATH)
		has_recording = true
	recording_state_changed.emit(false)


func play_recording() -> void:
	if not _last_recording or is_playing:
		return
	_playback_player.stream = _last_recording
	_playback_player.play()
	is_playing = true
	playback_state_changed.emit(true)


func stop_playback() -> void:
	if not is_playing:
		return
	_playback_player.stop()
	is_playing = false
	playback_state_changed.emit(false)


func set_repeat(enabled: bool) -> void:
	repeat_playback = enabled


func set_playback_volume_db(db: float) -> void:
	_playback_player.volume_db = db


func _do_start_recording() -> void:
	if not _mic_player:
		_mic_player = AudioStreamPlayer.new()
		_mic_player.stream = AudioStreamMicrophone.new()
		_mic_player.bus = RECORD_BUS
		add_child(_mic_player)
	_mic_player.play()
	_record_effect.set_recording_active(true)
	is_recording = true
	recording_state_changed.emit(true)


func _ensure_record_bus() -> void:
	var idx := AudioServer.get_bus_index(RECORD_BUS)
	if idx == -1:
		idx = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, RECORD_BUS)
		AudioServer.set_bus_send(idx, "Master")
		AudioServer.set_bus_mute(idx, true)
		_record_effect = AudioEffectRecord.new()
		AudioServer.add_bus_effect(idx, _record_effect)
	else:
		_record_effect = AudioServer.get_bus_effect(idx, 0)


func _ensure_playback_bus() -> void:
	var idx := AudioServer.get_bus_index(PLAYBACK_BUS)
	if idx == -1:
		idx = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, PLAYBACK_BUS)
		AudioServer.set_bus_send(idx, "Master")
		var band_pass := AudioEffectBandPassFilter.new()
		band_pass.cutoff_hz = 1200.0
		band_pass.resonance = 1.2
		AudioServer.add_bus_effect(idx, band_pass)
		var lofi := AudioEffectDistortion.new()
		lofi.mode = AudioEffectDistortion.MODE_LOFI
		lofi.drive = 0.35
		AudioServer.add_bus_effect(idx, lofi)


func _on_playback_finished() -> void:
	is_playing = false
	if repeat_playback and _last_recording:
		play_recording()
	else:
		playback_state_changed.emit(false)
