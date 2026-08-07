class_name SirenPlayer
extends AudioStreamPlayer

const MIX_RATE := 22050.0
const BUFFER_LENGTH := 0.2
const AMPLITUDE := 0.35

var siren_type: SignalPreset.SirenType = SignalPreset.SirenType.NONE
var beep_gate: bool = true

var _playback: AudioStreamGeneratorPlayback
var _tone_phase: float = 0.0
var _lfo_phase: float = 0.0


func _ready() -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = MIX_RATE
	generator.buffer_length = BUFFER_LENGTH
	stream = generator
	set_process(false)


func start(type: SignalPreset.SirenType) -> void:
	siren_type = type
	if type == SignalPreset.SirenType.NONE:
		stop_siren()
		return
	_tone_phase = 0.0
	_lfo_phase = 0.0
	beep_gate = true
	play()
	_playback = get_stream_playback()
	set_process(true)
	_fill_buffer()


func stop_siren() -> void:
	set_process(false)
	stop()
	_playback = null


func _process(_delta: float) -> void:
	_fill_buffer()


func _fill_buffer() -> void:
	if not _playback:
		return
	var frames := _playback.get_frames_available()
	var dt := 1.0 / MIX_RATE
	for _i in range(frames):
		var freq := _current_frequency()
		_tone_phase = fmod(_tone_phase + TAU * freq * dt, TAU)
		var sample := sin(_tone_phase) * _current_amplitude()
		_playback.push_frame(Vector2(sample, sample))
		_lfo_phase += dt


func _current_frequency() -> float:
	match siren_type:
		SignalPreset.SirenType.WAIL:
			return 700.0 + 350.0 * sin(TAU * _lfo_phase / 4.0)
		SignalPreset.SirenType.YELP:
			return 700.0 + 350.0 * sin(TAU * _lfo_phase / 0.8)
		SignalPreset.SirenType.TWO_TONE:
			return 500.0 if fmod(_lfo_phase, 1.0) < 0.5 else 750.0
		SignalPreset.SirenType.SOS_BEEP:
			return 800.0
		_:
			return 0.0


func _current_amplitude() -> float:
	if siren_type == SignalPreset.SirenType.SOS_BEEP:
		return AMPLITUDE if beep_gate else 0.0
	return AMPLITUDE
