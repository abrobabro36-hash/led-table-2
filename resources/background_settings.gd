class_name BackgroundSettings
extends Resource

enum Mode { SOLID, GRADIENT, IMAGE, TRUE_BLACK }

@export var mode: Mode = Mode.SOLID:
	set(value):
		mode = value
		emit_changed()

@export var solid_color: Color = Color(0.05, 0.05, 0.06):
	set(value):
		solid_color = value
		emit_changed()

@export var gradient_color_a: Color = Color(0.05, 0.05, 0.06):
	set(value):
		gradient_color_a = value
		emit_changed()

@export var gradient_color_b: Color = Color(0.15, 0.05, 0.2):
	set(value):
		gradient_color_b = value
		emit_changed()

@export_range(0.0, 360.0, 1.0, "suffix:°") var gradient_angle: float = 0.0:
	set(value):
		gradient_angle = value
		emit_changed()

## user:// path chosen via the native file dialog; empty means no image picked yet.
@export var image_path: String = "":
	set(value):
		image_path = value
		emit_changed()

@export_range(0.0, 1.0, 0.01) var opacity: float = 1.0:
	set(value):
		opacity = value
		emit_changed()
