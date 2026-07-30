class_name TextStyle
extends Resource

enum FontChoice { INTER, MANROPE, NUNITO_SANS }

@export var font_choice: FontChoice = FontChoice.INTER:
	set(value):
		font_choice = value
		emit_changed()

@export var bold: bool = false:
	set(value):
		bold = value
		emit_changed()

@export var italic: bool = false:
	set(value):
		italic = value
		emit_changed()

@export_range(0.0, 20.0, 0.5, "suffix:px") var letter_spacing: float = 0.0:
	set(value):
		letter_spacing = value
		emit_changed()

@export_range(8.0, 200.0, 1.0, "suffix:px") var base_font_size: float = 64.0:
	set(value):
		base_font_size = value
		emit_changed()

@export_range(0.2, 3.0, 0.01) var text_scale: float = 1.0:
	set(value):
		text_scale = value
		emit_changed()
