class_name LedPreviewFrame
extends PanelContainer

@onready var _content: Control = %Content


func get_content_container() -> Control:
	return _content


func set_accent(color: Color) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.018, 0.025, 0.035, 1)
	box.border_width_left = 1
	box.border_width_top = 1
	box.border_width_right = 1
	box.border_width_bottom = 1
	box.border_color = Color(color.r, color.g, color.b, 0.78)
	box.corner_radius_top_left = 16
	box.corner_radius_top_right = 16
	box.corner_radius_bottom_right = 16
	box.corner_radius_bottom_left = 16
	box.shadow_color = Color(color.r, color.g, color.b, 0.16)
	box.shadow_size = 10
	add_theme_stylebox_override("panel", box)

