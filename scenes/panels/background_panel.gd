class_name BackgroundPanel
extends PanelContainer

const MODE_NAMES := ["Сплошной цвет", "Градиент", "Изображение", "Чёрный (OLED)"]

@export var background: BackgroundSettings = preload("res://resources/default_background_settings.tres")
@export var color_picker: ColorPickerPanel

@onready var _mode_option: OptionButton = %ModeOption
@onready var _solid_row: HBoxContainer = %SolidRow
@onready var _solid_swatch: ColorRect = %SolidSwatch
@onready var _gradient_row: VBoxContainer = %GradientRow
@onready var _gradient_a_swatch: ColorRect = %GradientASwatch
@onready var _gradient_b_swatch: ColorRect = %GradientBSwatch
@onready var _gradient_angle_slider: HSlider = %GradientAngleSlider
@onready var _image_row: HBoxContainer = %ImageRow
@onready var _pick_photo_button: Button = %PickPhotoButton
@onready var _opacity_slider: HSlider = %OpacitySlider


func _ready() -> void:
	for mode_name in MODE_NAMES:
		_mode_option.add_item(mode_name)
	_mode_option.select(background.mode)
	_solid_swatch.color = background.solid_color
	_gradient_a_swatch.color = background.gradient_color_a
	_gradient_b_swatch.color = background.gradient_color_b
	_gradient_angle_slider.value = background.gradient_angle
	_opacity_slider.value = background.opacity
	_update_visible_rows()

	_mode_option.item_selected.connect(func(index: int) -> void:
		background.mode = index
		_update_visible_rows()
	)
	_solid_swatch.gui_input.connect(_on_swatch_input.bind(_solid_swatch, "solid"))
	_gradient_a_swatch.gui_input.connect(_on_swatch_input.bind(_gradient_a_swatch, "gradient_a"))
	_gradient_b_swatch.gui_input.connect(_on_swatch_input.bind(_gradient_b_swatch, "gradient_b"))
	_gradient_angle_slider.value_changed.connect(func(value: float) -> void: background.gradient_angle = value)
	_opacity_slider.value_changed.connect(func(value: float) -> void: background.opacity = value)
	_pick_photo_button.pressed.connect(_pick_photo)


func _update_visible_rows() -> void:
	_solid_row.visible = background.mode == BackgroundSettings.Mode.SOLID
	_gradient_row.visible = background.mode == BackgroundSettings.Mode.GRADIENT
	_image_row.visible = background.mode == BackgroundSettings.Mode.IMAGE


func _on_swatch_input(event: InputEvent, swatch: ColorRect, target: String) -> void:
	if event is InputEventMouseButton and event.pressed:
		if color_picker.color_picked.is_connected(_on_color_picked):
			color_picker.color_picked.disconnect(_on_color_picked)
		color_picker.color_picked.connect(_on_color_picked.bind(swatch, target))
		color_picker.open_for(swatch.color)


func _on_color_picked(color: Color, swatch: ColorRect, target: String) -> void:
	swatch.color = color
	match target:
		"solid":
			background.solid_color = color
		"gradient_a":
			background.gradient_color_a = color
		"gradient_b":
			background.gradient_color_b = color


func _pick_photo() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE):
		return
	DisplayServer.file_dialog_show(
		"Выбрать фото",
		"",
		"",
		false,
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,
		["*.png,*.jpg,*.jpeg,*.webp ; Изображения"],
		_on_photo_selected
	)


func _on_photo_selected(status: bool, selected_paths: PackedStringArray, _filter_index: int) -> void:
	if not status or selected_paths.is_empty():
		return
	var picked_path: String = selected_paths[0]
	var image := Image.new()
	if image.load(picked_path) != OK:
		return
	DirAccess.make_dir_recursive_absolute("user://backgrounds")
	var dest_path := "user://backgrounds/bg_%d.png" % Time.get_unix_time_from_system()
	if image.save_png(dest_path) == OK:
		background.image_path = dest_path
