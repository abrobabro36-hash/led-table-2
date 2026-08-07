class_name AudioReactor
extends Node

const BUS_NAME := "Mic"
const RECORD_AUDIO_PERMISSION := "android.permission.RECORD_AUDIO"

var volume: float = 0.0
var bass: float = 0.0
var mid: float = 0.0
var treble: float = 0.0

var _mic_player: AudioStreamPlayer
var _spectrum: AudioEffectSpectrumAnalyzerInstance
var _active: bool = false


func _ready() -> void:
	set_process(false)


func start() -> void:
	if not _has_permission():
		if OS.get_name() == "Android":
			OS.request_permissions()
		return
	_begin_capture()


func stop() -> void:
	_active = false
	set_process(false)
	if _mic_player:
		_mic_player.stop()
	volume = 0.0
	bass = 0.0
	mid = 0.0
	treble = 0.0


func _has_permission() -> bool:
	if OS.get_name() != "Android":
		return true
	return RECORD_AUDIO_PERMISSION in OS.get_granted_permissions()


func _ensure_bus() -> int:
	var idx := AudioServer.get_bus_index(BUS_NAME)
	if idx == -1:
		idx = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, BUS_NAME)
		AudioServer.set_bus_send(idx, "Master")
		AudioServer.set_bus_mute(idx, true)
		AudioServer.add_bus_effect(idx, AudioEffectSpectrumAnalyzer.new())
	return idx


func _begin_capture() -> void:
	if _active:
		return
	var bus_idx := _ensure_bus()
	if not _mic_player:
		_mic_player = AudioStreamPlayer.new()
		_mic_player.stream = AudioStreamMicrophone.new()
		_mic_player.bus = BUS_NAME
		add_child(_mic_player)
	_mic_player.play()
	_spectrum = AudioServer.get_bus_effect_instance(bus_idx, 0)
	_active = true
	set_process(true)


func _process(_delta: float) -> void:
	if not _spectrum:
		return
	bass = _band_level(60.0, 250.0)
	mid = _band_level(250.0, 2000.0)
	treble = _band_level(2000.0, 8000.0)
	volume = clampf((bass + mid + treble) / 3.0, 0.0, 1.0)


func _band_level(freq_from: float, freq_to: float) -> float:
	var magnitude: Vector2 = _spectrum.get_magnitude_for_frequency_range(freq_from, freq_to)
	var db := linear_to_db(magnitude.length())
	return clampf((db + 60.0) / 60.0, 0.0, 1.0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and not _active:
		if _has_permission():
			_begin_capture()
