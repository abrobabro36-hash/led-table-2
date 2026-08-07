class_name ThematicPlayer
extends Node

signal preset_activated(preset: ThematicPreset)
signal preset_deactivated

enum Phase { DECORATIVE, TEXT }

var preset: ThematicPreset
var active: bool = false
## When false, the cycle never advances to the text phase — decorative animation loops forever.
var show_text: bool = true

var _phase: Phase = Phase.DECORATIVE
var _phase_elapsed: float = 0.0
var _spawn_elapsed: float = 0.0
var _text_phase_duration: float = 3.0
var _current_text: String = ""
var _waiting_for_cycle_signal: bool = false
var _rng := RandomNumberGenerator.new()
var _particles: Array[Label] = []

var _layer: Control
var _source_label: RichTextLabel
var _text_animator: TextAnimator
var _audio_reactor: AudioReactor


func setup(layer: Control, source_label: RichTextLabel, text_animator: TextAnimator, audio_reactor: AudioReactor) -> void:
	_layer = layer
	_source_label = source_label
	_text_animator = text_animator
	_audio_reactor = audio_reactor
	set_process(false)


func activate(p: ThematicPreset, current_text: String) -> void:
	preset = p
	_current_text = current_text
	active = true
	_phase = Phase.DECORATIVE
	_phase_elapsed = 0.0
	_spawn_elapsed = 0.0
	_layer.visible = true
	_source_label.visible = false
	_clear_particles()
	if preset.reacts_to_audio:
		_audio_reactor.start()
	set_process(true)
	preset_activated.emit(preset)


func deactivate() -> void:
	if not active:
		return
	active = false
	set_process(false)
	_disconnect_cycle_signal()
	_audio_reactor.stop()
	_clear_particles()
	_layer.visible = false
	_source_label.visible = true
	_text_animator.stop()
	preset_deactivated.emit()


func _process(delta: float) -> void:
	_phase_elapsed += delta
	match _phase:
		Phase.DECORATIVE:
			_spawn_elapsed += delta
			var interval := preset.spawn_interval
			if preset.reacts_to_audio:
				interval = maxf(0.08, preset.spawn_interval * (1.0 - _audio_reactor.volume * 0.8))
			if _spawn_elapsed >= interval:
				_spawn_elapsed = 0.0
				_spawn_particle()
			if _phase_elapsed >= preset.decorative_duration:
				_advance_phase()
		Phase.TEXT:
			if not _waiting_for_cycle_signal and _phase_elapsed >= _text_phase_duration:
				_advance_phase()


func _advance_phase() -> void:
	_phase_elapsed = 0.0
	_disconnect_cycle_signal()
	if _phase == Phase.DECORATIVE:
		if _current_text.is_empty() or not show_text:
			return
		_phase = Phase.TEXT
		_layer.visible = false
		_source_label.visible = true
		_text_animator.play()
		if _text_animator.uses_cycle_signal():
			_waiting_for_cycle_signal = true
			_text_animator.cycle_completed.connect(_on_text_cycle_completed)
		else:
			_text_phase_duration = _estimate_text_duration()
	else:
		_phase = Phase.DECORATIVE
		_layer.visible = true
		_source_label.visible = false
		_text_animator.stop()
		_clear_particles()


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


func _spawn_particle() -> void:
	if _layer.size.x < 1.0 or preset.symbols.is_empty():
		return
	var label := Label.new()
	label.text = preset.symbols[_rng.randi() % preset.symbols.size()]
	label.add_theme_font_size_override("font_size", int(preset.particle_font_size))
	if preset.palette and preset.palette.colors.size() > 0:
		label.add_theme_color_override("font_color", preset.palette.colors[_rng.randi() % preset.palette.colors.size()])
	label.modulate.a = 0.0
	label.pivot_offset = Vector2(preset.particle_font_size, preset.particle_font_size) * 0.5
	_layer.add_child(label)
	_particles.append(label)
	var start_x := _rng.randf_range(0.0, maxf(_layer.size.x - preset.particle_font_size, 1.0))
	match preset.movement:
		ThematicPreset.Movement.FLOAT_UP:
			label.position = Vector2(start_x, _layer.size.y - preset.particle_font_size)
			_animate_float_up(label)
		ThematicPreset.Movement.TWINKLE_FALL:
			label.position = Vector2(start_x, -preset.particle_font_size)
			_animate_twinkle_fall(label)


func _animate_float_up(label: Label) -> void:
	var duration := preset.particle_lifetime
	var boost := 1.0 + (_audio_reactor.volume * 0.6 if preset.reacts_to_audio else 0.0)
	var tween := create_tween()
	label.set_meta("tween", tween)
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", -preset.particle_font_size, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "modulate:a", 1.0, duration * 0.2)
	tween.tween_property(label, "scale", Vector2.ONE * boost, duration * 0.3).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(label, "modulate:a", 0.0, duration * 0.3)
	tween.chain().tween_callback(_remove_particle.bind(label))


func _animate_twinkle_fall(label: Label) -> void:
	var duration := preset.particle_lifetime
	var tween := create_tween()
	label.set_meta("tween", tween)
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", _layer.size.y + preset.particle_font_size, duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label, "modulate:a", 1.0, duration * 0.15)
	tween.chain().tween_property(label, "modulate:a", 0.0, duration * 0.25)
	tween.chain().tween_callback(_remove_particle.bind(label))


func _remove_particle(label: Label) -> void:
	_particles.erase(label)
	if is_instance_valid(label):
		label.queue_free()


func _clear_particles() -> void:
	for particle in _particles:
		if is_instance_valid(particle):
			var tween: Tween = particle.get_meta("tween", null)
			if tween:
				tween.kill()
			particle.queue_free()
	_particles.clear()
