class_name LedBoard
extends Control

const FONT_FILES := {
	TextStyle.FontChoice.INTER: {
		"upright": "res://theme/fonts/Inter-Variable.ttf",
		"italic": "res://theme/fonts/Inter-Italic-Variable.ttf",
	},
	TextStyle.FontChoice.MANROPE: {
		"upright": "res://theme/fonts/Manrope-Variable.ttf",
		"italic": "",
	},
	TextStyle.FontChoice.NUNITO_SANS: {
		"upright": "res://theme/fonts/NunitoSans-Variable.ttf",
		"italic": "res://theme/fonts/NunitoSans-Italic-Variable.ttf",
	},
}

@export var settings: LedSettings = preload("res://resources/default_led_settings.tres"):
	set(value):
		if settings and settings.changed.is_connected(_apply_led_settings):
			settings.changed.disconnect(_apply_led_settings)
		settings = value
		if is_node_ready() and settings:
			settings.changed.connect(_apply_led_settings)
			_apply_led_settings()

@export var text_style: TextStyle = preload("res://resources/default_text_style.tres"):
	set(value):
		if text_style and text_style.changed.is_connected(_apply_text_style):
			text_style.changed.disconnect(_apply_text_style)
		text_style = value
		if is_node_ready() and text_style:
			text_style.changed.connect(_apply_text_style)
			_apply_text_style()

@export var animation: AnimationSettings = preload("res://resources/default_animation_settings.tres"):
	set(value):
		animation = value
		if is_node_ready():
			_text_animator.settings = value

@export_multiline var text: String = "LED Display 🎉":
	set(value):
		text = value
		if is_node_ready():
			_text_animator.set_raw_text(value)

@onready var _sub_viewport: SubViewport = $SubViewport
@onready var _source_label: RichTextLabel = $SubViewport/SourceLabel
@onready var _display_rect: ColorRect = $DotMatrixDisplay
@onready var _world_environment: WorldEnvironment = $WorldEnvironment
@onready var _text_animator: TextAnimator = $TextAnimator


func _ready() -> void:
	_world_environment.environment = preload("res://resources/led_glow_environment.tres").duplicate()
	var mat := _display_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("source_tex", _sub_viewport.get_texture())
	if settings:
		settings.changed.connect(_apply_led_settings)
	if text_style:
		text_style.changed.connect(_apply_text_style)
	_apply_text_style()
	_text_animator.setup(_source_label, animation)
	_text_animator.set_raw_text(text)
	resized.connect(_on_resized)
	_on_resized()
	_apply_led_settings()


func play() -> void:
	_text_animator.play()


func pause() -> void:
	_text_animator.pause()


func stop() -> void:
	_text_animator.stop()


func _on_resized() -> void:
	if size.x < 1.0 or size.y < 1.0:
		return
	_sub_viewport.size = Vector2i(size)
	_text_animator.set_viewport_size(size)
	var mat := _display_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("rect_size", size)


func _apply_led_settings() -> void:
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


func _apply_text_style() -> void:
	if not text_style or not is_node_ready():
		return
	var entry: Dictionary = FONT_FILES[text_style.font_choice]
	var use_italic: bool = text_style.italic and entry["italic"] != ""
	var font_path: String = entry["italic"] if use_italic else entry["upright"]
	var variation := FontVariation.new()
	variation.base_font = load(font_path)
	if text_style.bold:
		variation.variation_opentype = {"wght": 700.0}
	variation.set_spacing(TextServer.SPACING_GLYPH, int(text_style.letter_spacing))
	_source_label.add_theme_font_override("normal_font", variation)
	var font_size := int(text_style.base_font_size * text_style.text_scale)
	_source_label.add_theme_font_size_override("normal_font_size", font_size)
	_source_label.custom_minimum_size = Vector2.ZERO
	_source_label.reset_size()
	if is_instance_valid(_text_animator):
		_text_animator.set_viewport_size(size)
