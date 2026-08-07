class_name SignalPlayer
extends Node

signal preset_activated(preset: SignalPreset)
signal preset_deactivated

const BLINK_PERIOD := 0.6

const DOT := 0.2
const DASH := 0.6
const INTRA_GAP := 0.2
const LETTER_GAP := 0.6
const WORD_GAP := 1.4
const SOS_SEGMENTS: Array[float] = [
	DOT, INTRA_GAP, DOT, INTRA_GAP, DOT, LETTER_GAP,
	DASH, INTRA_GAP, DASH, INTRA_GAP, DASH, LETTER_GAP,
	DOT, INTRA_GAP, DOT, INTRA_GAP, DOT, WORD_GAP,
]

enum Phase { SIGNAL, TEXT }

var preset: SignalPreset
var pattern: SignalPreset.BlinkPattern = SignalPreset.BlinkPattern.SYNC
var active: bool = false
## When false, the cycle never advances to the text phase — signal loops forever.
var show_text: bool = true

var _phase: Phase = Phase.SIGNAL
var _phase_elapsed: float = 0.0
var _t: float = 0.0
var _text_phase_duration: float = 3.0
var _current_text: String = ""
var _waiting_for_cycle_signal: bool = false

var _left_rect: ColorRect
var _right_rect: ColorRect
var _signal_graphic: Control
var _source_label: RichTextLabel
var _text_animator: TextAnimator
var _siren: SirenPlayer


func setup(signal_graphic: Control, left: ColorRect, right: ColorRect, source_label: RichTextLabel, text_animator: TextAnimator, siren: SirenPlayer) -> void:
	_signal_graphic = signal_graphic
	_left_rect = left
	_right_rect = right
	_source_label = source_label
	_text_animator = text_animator
	_siren = siren
	set_process(false)


func activate(p: SignalPreset, chosen_pattern: SignalPreset.BlinkPattern, current_text: String) -> void:
	preset = p
	pattern = chosen_pattern
	_current_text = current_text
	active = true
	_phase = Phase.SIGNAL
	_phase_elapsed = 0.0
	_t = 0.0
	_signal_graphic.visible = true
	_source_label.visible = false
	_siren.start(preset.siren_type)
	set_process(true)
	preset_activated.emit(preset)


func deactivate() -> void:
	if not active:
		return
	active = false
	set_process(false)
	_disconnect_cycle_signal()
	_signal_graphic.visible = false
	_source_label.visible = true
	_left_rect.color = Color(0, 0, 0, 0)
	_right_rect.color = Color(0, 0, 0, 0)
	_siren.stop_siren()
	_text_animator.stop()
	preset_deactivated.emit()


func _process(delta: float) -> void:
	_t += delta
	_phase_elapsed += delta
	match _phase:
		Phase.SIGNAL:
			_apply_pattern(_t)
			if pattern == SignalPreset.BlinkPattern.SOS_MORSE:
				_siren.beep_gate = _sos_is_on(_t)
			if _phase_elapsed >= preset.signal_duration:
				_advance_phase()
		Phase.TEXT:
			if not _waiting_for_cycle_signal and _phase_elapsed >= _text_phase_duration:
				_advance_phase()


func _advance_phase() -> void:
	_phase_elapsed = 0.0
	_disconnect_cycle_signal()
	if _phase == Phase.SIGNAL:
		if _current_text.is_empty() or not show_text:
			return
		_phase = Phase.TEXT
		_signal_graphic.visible = false
		_source_label.visible = true
		_text_animator.play()
		if _text_animator.uses_cycle_signal():
			_waiting_for_cycle_signal = true
			_text_animator.cycle_completed.connect(_on_text_cycle_completed)
		else:
			_text_phase_duration = _estimate_text_duration()
	else:
		_phase = Phase.SIGNAL
		_signal_graphic.visible = true
		_source_label.visible = false
		_text_animator.stop()


func _on_text_cycle_completed() -> void:
	if _phase == Phase.TEXT:
		_advance_phase()


func _disconnect_cycle_signal() -> void:
	_waiting_for_cycle_signal = false
	if _text_animator.cycle_completed.is_connected(_on_text_cycle_completed):
		_text_animator.cycle_completed.disconnect(_on_text_cycle_completed)


func _estimate_text_duration() -> float:
	var speed := 1.0
	if _text_animator.settings:
		speed = maxf(_text_animator.settings.speed, 0.1)
	return maxf(3.0, _current_text.length() * 0.15 / speed)


func _apply_pattern(t: float) -> void:
	var period := BLINK_PERIOD / maxf(preset.blink_speed, 0.05)
	var on_left := true
	var on_right := true
	match pattern:
		SignalPreset.BlinkPattern.SYNC:
			var on := fmod(t, period) < period * 0.5
			on_left = on
			on_right = on
		SignalPreset.BlinkPattern.ALTERNATE:
			var on := fmod(t, period) < period * 0.5
			on_left = on
			on_right = not on
		SignalPreset.BlinkPattern.WIG_WAG:
			var fast_period := period * 0.4
			var on := fmod(t, fast_period) < fast_period * 0.5
			on_left = on
			on_right = not on
		SignalPreset.BlinkPattern.SOS_MORSE:
			var on := _sos_is_on(t)
			on_left = on
			on_right = on
	_left_rect.color = Color(preset.color_a.r, preset.color_a.g, preset.color_a.b, 1.0 if on_left else 0.0)
	_right_rect.color = Color(preset.color_b.r, preset.color_b.g, preset.color_b.b, 1.0 if on_right else 0.0)


func _sos_is_on(t: float) -> bool:
	var total := 0.0
	for d in SOS_SEGMENTS:
		total += d
	var local := fmod(t, total)
	var acc := 0.0
	var idx := 0
	for d in SOS_SEGMENTS:
		if local < acc + d:
			return idx % 2 == 0
		acc += d
		idx += 1
	return false
