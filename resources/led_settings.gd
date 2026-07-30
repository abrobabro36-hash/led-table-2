class_name LedSettings
extends Resource

enum DotShape { CIRCLE, SQUARE, DIAMOND }

@export var dot_shape: DotShape = DotShape.CIRCLE:
	set(value):
		dot_shape = value
		emit_changed()

@export_range(2.0, 64.0, 0.5, "suffix:px") var dot_size: float = 6.0:
	set(value):
		dot_size = value
		emit_changed()

@export_range(2.0, 64.0, 0.5, "suffix:px") var dot_spacing: float = 10.0:
	set(value):
		dot_spacing = value
		emit_changed()

@export_range(0.0, 2.0, 0.01) var brightness: float = 1.0:
	set(value):
		brightness = value
		emit_changed()

@export_range(0.0, 1.0, 0.01) var blur: float = 0.15:
	set(value):
		blur = value
		emit_changed()

@export var glow_enabled: bool = true:
	set(value):
		glow_enabled = value
		emit_changed()

@export_range(0.0, 3.0, 0.01) var glow_strength: float = 0.8:
	set(value):
		glow_strength = value
		emit_changed()

## Whether the dot-grid overlay is shown at all; when false, text renders crisp and unmasked.
@export var mask_enabled: bool = true:
	set(value):
		mask_enabled = value
		emit_changed()

## Color of the text revealed through the mask (applied to the text itself, not the shader).
@export var text_color: Color = Color(1.0, 0.15, 0.15):
	set(value):
		text_color = value
		emit_changed()

## Color of the gaps between dots in the mask.
@export var gap_color: Color = Color(0.07, 0.07, 0.08):
	set(value):
		gap_color = value
		emit_changed()
