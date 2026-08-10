class_name AccentTheme
extends RefCounted


static func build_stylebox(base: StyleBoxFlat, color: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = base.duplicate()
	box.bg_color = color
	return box


static func readable_text_color(bg: Color) -> Color:
	return Color.BLACK if bg.get_luminance() > 0.6 else Color.WHITE


## For toggle-mode buttons (tabs, style pickers) — tints only the pressed state.
static func tint_toggle_button(button: Button, box: StyleBoxFlat, text_color: Color) -> void:
	button.add_theme_stylebox_override("pressed", box)
	button.add_theme_color_override("font_pressed_color", text_color)


## For a plain button whose "active" state isn't toggle_mode (e.g. Start/Stop) —
## tints normal+hover while active, reverts to the default theme otherwise.
static func tint_active_button(button: Button, box: StyleBoxFlat, text_color: Color, active: bool) -> void:
	if active:
		button.add_theme_stylebox_override("normal", box)
		button.add_theme_stylebox_override("hover", box)
		button.add_theme_color_override("font_color", text_color)
		button.add_theme_color_override("font_hover_color", text_color)
	else:
		button.remove_theme_stylebox_override("normal")
		button.remove_theme_stylebox_override("hover")
		button.remove_theme_color_override("font_color")
		button.remove_theme_color_override("font_hover_color")
