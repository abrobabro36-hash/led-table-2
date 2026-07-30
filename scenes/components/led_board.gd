class_name LedBoard
extends Control

@export var settings: LedSettings = preload("res://resources/default_led_settings.tres"):
	set(value):
		if settings and settings.changed.is_connected(_apply_settings):
			settings.changed.disconnect(_apply_settings)
		settings = value
		if is_node_ready() and settings:
			settings.changed.connect(_apply_settings)
			_apply_settings()

@export_multiline var text: String = "LED Display 🎉":
	set(value):
		text = value
		if is_node_ready():
			_source_label.text = value

@onready var _sub_viewport: SubViewport = $SubViewport
@onready var _source_label: Label = $SubViewport/SourceLabel
@onready var _display_rect: ColorRect = $DotMatrixDisplay
@onready var _world_environment: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	_world_environment.environment = preload("res://resources/led_glow_environment.tres").duplicate()
	_source_label.text = text
	var mat := _display_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("source_tex", _sub_viewport.get_texture())
	if settings:
		settings.changed.connect(_apply_settings)
	resized.connect(_on_resized)
	_on_resized()
	_apply_settings()


func _on_resized() -> void:
	if size.x < 1.0 or size.y < 1.0:
		return
	_sub_viewport.size = Vector2i(size)
	var mat := _display_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("rect_size", size)


func _apply_settings() -> void:
	if not settings:
		return
	var mat := _display_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("dot_shape", settings.dot_shape)
		mat.set_shader_parameter("dot_radius_px", settings.dot_size)
		mat.set_shader_parameter("dot_spacing_px", settings.dot_spacing)
		mat.set_shader_parameter("blur_amount", settings.blur)
		mat.set_shader_parameter("brightness", settings.brightness)
		mat.set_shader_parameter("color_on", settings.color_on)
		mat.set_shader_parameter("color_off", settings.color_off)
	if _world_environment.environment:
		_world_environment.environment.glow_enabled = settings.glow_enabled
		_world_environment.environment.glow_strength = settings.glow_strength
