class_name ColorPickerPanel
extends PopupPanel

signal color_picked(color: Color)

const PALETTE_PATHS := [
	"res://resources/palettes/classic.tres",
	"res://resources/palettes/neon.tres",
	"res://resources/palettes/pastel.tres",
]

@onready var _picker: ColorPicker = %ColorPicker
@onready var _palettes_list: VBoxContainer = %PalettesList
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	_picker.color_changed.connect(func(color: Color) -> void: color_picked.emit(color))
	_close_button.pressed.connect(hide)
	for path in PALETTE_PATHS:
		_add_palette_row(load(path))


func open_for(current_color: Color) -> void:
	_picker.color = current_color
	popup_centered(Vector2i(420, 620))


func _add_palette_row(palette: AppColorPalette) -> void:
	var label := Label.new()
	label.text = palette.palette_name
	_palettes_list.add_child(label)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_palettes_list.add_child(row)

	for c in palette.colors:
		var swatch := ColorRect.new()
		swatch.color = c
		swatch.custom_minimum_size = Vector2(36, 36)
		swatch.mouse_filter = Control.MOUSE_FILTER_STOP
		swatch.gui_input.connect(_on_swatch_input.bind(c))
		row.add_child(swatch)


func _on_swatch_input(event: InputEvent, color: Color) -> void:
	if event is InputEventMouseButton and event.pressed:
		_picker.color = color
		color_picked.emit(color)
