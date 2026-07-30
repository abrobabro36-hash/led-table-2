class_name AnimationSettings
extends Resource

enum Mode {
	STATIC,
	SCROLL_HORIZONTAL,
	SCROLL_VERTICAL,
	BLINK,
	TYPEWRITER,
	PULSE,
	WAVE,
	BOUNCE,
}

@export var mode: Mode = Mode.STATIC:
	set(value):
		mode = value
		emit_changed()

## Only relevant for the two scroll modes: false = left-to-right / top-to-bottom.
@export var scroll_reverse: bool = false:
	set(value):
		scroll_reverse = value
		emit_changed()

@export_range(0.1, 3.0, 0.01) var speed: float = 1.0:
	set(value):
		speed = value
		emit_changed()
