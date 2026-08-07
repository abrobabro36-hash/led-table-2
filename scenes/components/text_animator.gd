class_name TextAnimator
extends Node

## Emitted when a scroll/typewriter mode finishes one full pass. Modes without
## a natural "one pass" endpoint (static/blink/pulse/wave/bounce) never emit this.
signal cycle_completed

enum PlayState { STOPPED, PLAYING, PAUSED }

var target: RichTextLabel
var viewport_size: Vector2 = Vector2.ZERO
var raw_text: String = ""

var settings: AnimationSettings:
	set(value):
		if settings and settings.changed.is_connected(_on_settings_changed):
			settings.changed.disconnect(_on_settings_changed)
		settings = value
		if settings:
			settings.changed.connect(_on_settings_changed)
		_reset_for_mode()

var _state: PlayState = PlayState.STOPPED
var _elapsed: float = 0.0
var _bounce_tween: Tween
var _prev_typewriter_phase: float = 0.0


func _ready() -> void:
	set_process(false)


func setup(p_target: RichTextLabel, p_settings: AnimationSettings) -> void:
	target = p_target
	settings = p_settings


func set_raw_text(value: String) -> void:
	raw_text = value
	if target == null or settings == null:
		return
	if settings.mode == AnimationSettings.Mode.WAVE:
		_apply_wave_text()
	else:
		target.text = raw_text
	_recenter_static_axis()


func set_viewport_size(p_size: Vector2) -> void:
	viewport_size = p_size
	if _state != PlayState.PLAYING:
		_reset_for_mode()


func play() -> void:
	if _state == PlayState.STOPPED:
		_reset_for_mode()
	_state = PlayState.PLAYING
	set_process(_mode_needs_process())


func pause() -> void:
	_state = PlayState.PAUSED
	set_process(false)


func stop() -> void:
	_state = PlayState.STOPPED
	set_process(false)
	_reset_for_mode()


func _mode_needs_process() -> bool:
	return settings != null and settings.mode not in [AnimationSettings.Mode.STATIC, AnimationSettings.Mode.WAVE]


## Whether this mode reports real pass-completion via `cycle_completed` (scroll/typewriter),
## as opposed to having no natural "fully shown" moment (blink/pulse/wave/bounce/static).
func uses_cycle_signal() -> bool:
	return settings != null and settings.mode in [
		AnimationSettings.Mode.SCROLL_HORIZONTAL,
		AnimationSettings.Mode.SCROLL_VERTICAL,
		AnimationSettings.Mode.TYPEWRITER,
	]


func _on_settings_changed() -> void:
	if _state == PlayState.PLAYING:
		set_process(_mode_needs_process())
	else:
		_reset_for_mode()


func _centered_x() -> float:
	return (viewport_size.x - target.size.x) / 2.0


func _centered_y() -> float:
	return (viewport_size.y - target.size.y) / 2.0


func _recenter_static_axis() -> void:
	if target == null or settings == null or _state == PlayState.PLAYING:
		return
	target.pivot_offset = target.size / 2.0
	target.position = Vector2(_centered_x(), _centered_y())


func _apply_wave_text() -> void:
	var escaped := raw_text.replace("[", "[lb]")
	var freq := 2.0 * settings.speed
	target.text = "[wave amp=16.0 freq=%.2f]%s[/wave]" % [freq, escaped]


func _reset_for_mode() -> void:
	_elapsed = 0.0
	_prev_typewriter_phase = 0.0
	if target == null or settings == null:
		return
	target.modulate = Color(1, 1, 1, 1)
	target.scale = Vector2.ONE
	target.visible_characters = -1
	target.bbcode_enabled = settings.mode == AnimationSettings.Mode.WAVE
	if settings.mode == AnimationSettings.Mode.WAVE:
		_apply_wave_text()
	else:
		target.text = raw_text
	target.pivot_offset = target.size / 2.0

	match settings.mode:
		AnimationSettings.Mode.SCROLL_HORIZONTAL:
			target.position = Vector2(
				-target.size.x if settings.scroll_reverse else viewport_size.x,
				_centered_y()
			)
		AnimationSettings.Mode.SCROLL_VERTICAL:
			target.position = Vector2(
				_centered_x(),
				-target.size.y if settings.scroll_reverse else viewport_size.y
			)
		AnimationSettings.Mode.TYPEWRITER:
			target.position = Vector2(_centered_x(), _centered_y())
			target.visible_characters = 0
		AnimationSettings.Mode.BOUNCE:
			target.position = Vector2(_centered_x(), _centered_y())
			target.scale = Vector2(0.2, 0.2)
		_:
			target.position = Vector2(_centered_x(), _centered_y())


func _process(delta: float) -> void:
	if target == null or settings == null:
		return
	_elapsed += delta * settings.speed
	match settings.mode:
		AnimationSettings.Mode.SCROLL_HORIZONTAL:
			_process_scroll_horizontal(delta)
		AnimationSettings.Mode.SCROLL_VERTICAL:
			_process_scroll_vertical(delta)
		AnimationSettings.Mode.BLINK:
			_process_blink()
		AnimationSettings.Mode.TYPEWRITER:
			_process_typewriter()
		AnimationSettings.Mode.PULSE:
			_process_pulse()
		AnimationSettings.Mode.BOUNCE:
			_process_bounce()


func _process_scroll_horizontal(delta: float) -> void:
	var dir := 1.0 if settings.scroll_reverse else -1.0
	var px_per_sec := 140.0 * settings.speed
	target.position.x += dir * px_per_sec * delta
	target.position.y = _centered_y()
	var w := target.size.x
	if dir < 0.0 and target.position.x < -w:
		target.position.x = viewport_size.x
		cycle_completed.emit()
	elif dir > 0.0 and target.position.x > viewport_size.x:
		target.position.x = -w
		cycle_completed.emit()


func _process_scroll_vertical(delta: float) -> void:
	var dir := 1.0 if settings.scroll_reverse else -1.0
	var px_per_sec := 140.0 * settings.speed
	target.position.y += dir * px_per_sec * delta
	target.position.x = _centered_x()
	var h := target.size.y
	if dir < 0.0 and target.position.y < -h:
		target.position.y = viewport_size.y
		cycle_completed.emit()
	elif dir > 0.0 and target.position.y > viewport_size.y:
		target.position.y = -h
		cycle_completed.emit()


func _process_blink() -> void:
	var interval := 0.5 / settings.speed
	var phase := fmod(_elapsed, interval * 2.0)
	target.modulate.a = 1.0 if phase < interval else 0.0


func _process_typewriter() -> void:
	var total_chars := target.get_total_character_count()
	if total_chars <= 0:
		return
	var chars_per_sec := 10.0 * settings.speed
	var reveal_time := float(total_chars) / chars_per_sec
	var pause_time := 1.0 / settings.speed
	var cycle := reveal_time + pause_time
	var phase := fmod(_elapsed, cycle)
	target.visible_characters = clampi(int(phase * chars_per_sec), 0, total_chars)
	if phase < _prev_typewriter_phase:
		cycle_completed.emit()
	_prev_typewriter_phase = phase


func _process_pulse() -> void:
	var wave := 0.5 + 0.5 * sin(_elapsed * 2.0)
	target.modulate.a = lerpf(0.55, 1.0, wave)
	var s := lerpf(0.94, 1.0, wave)
	target.scale = Vector2(s, s)


func _process_bounce() -> void:
	var cycle := 2.5 / settings.speed
	var phase := fmod(_elapsed, cycle)
	if phase < 0.02 and (_bounce_tween == null or not _bounce_tween.is_running()):
		_trigger_bounce()


func _trigger_bounce() -> void:
	target.scale = Vector2(0.2, 0.2)
	if _bounce_tween:
		_bounce_tween.kill()
	_bounce_tween = create_tween()
	_bounce_tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_bounce_tween.tween_property(target, "scale", Vector2.ONE, 0.8 / settings.speed)
