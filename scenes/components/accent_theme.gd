class_name AccentTheme
extends RefCounted


static func build_stylebox(base: StyleBoxFlat, color: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = base.duplicate()
	box.bg_color = color
	return box


## Builds a presentation-only surface that keeps the mode accent at the edge
## instead of flooding a whole screen with color.
static func build_accent_surface(color: Color, radius: int = 16) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.035, 0.05, 0.07, 0.98)
	box.border_width_left = 1
	box.border_width_top = 1
	box.border_width_right = 1
	box.border_width_bottom = 1
	box.border_color = Color(color.r, color.g, color.b, 0.72)
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_right = radius
	box.corner_radius_bottom_left = radius
	box.shadow_color = Color(color.r, color.g, color.b, 0.12)
	box.shadow_size = 8
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


static func tint_panel(panel: PanelContainer, color: Color, radius: int = 16) -> void:
	panel.add_theme_stylebox_override("panel", build_accent_surface(color, radius))
