class_name LedBoard
extends Control

signal preset_activated(preset: SignalPreset)
signal preset_deactivated

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

@export var background: BackgroundSettings = preload("res://resources/default_background_settings.tres"):
	set(value):
		if background and background.changed.is_connected(_apply_background):
			background.changed.disconnect(_apply_background)
		background = value
		if is_node_ready() and background:
			background.changed.connect(_apply_background)
			_apply_background()

@export_multiline var text: String = "LED Display 🎉":
	set(value):
		text = value
		if is_node_ready():
			_text_animator.set_raw_text(value)

@onready var _sub_viewport: SubViewport = $SubViewport
@onready var _background_layer: Control = $SubViewport/BackgroundLayer
@onready var _solid_rect: ColorRect = $SubViewport/BackgroundLayer/SolidColorRect
@onready var _gradient_rect: TextureRect = $SubViewport/BackgroundLayer/GradientRect
@onready var _image_rect: TextureRect = $SubViewport/BackgroundLayer/ImageRect
@onready var _source_label: RichTextLabel = $SubViewport/SourceLabel
@onready var _signal_graphic: Control = $SubViewport/SignalGraphic
@onready var _signal_left_rect: ColorRect = $SubViewport/SignalGraphic/LeftRect
@onready var _signal_right_rect: ColorRect = $SubViewport/SignalGraphic/RightRect
@onready var _display_rect: ColorRect = $DotMatrixDisplay
@onready var _world_environment: WorldEnvironment = $WorldEnvironment
@onready var _text_animator: TextAnimator = $TextAnimator
@onready var _signal_player: SignalPlayer = $SignalPlayer
@onready var _siren_player: SirenPlayer = $SirenPlayer

var _gradient_texture: GradientTexture2D
var _loaded_image_path: String = ""


func _ready() -> void:
	_world_environment.environment = preload("res://resources/led_glow_environment.tres").duplicate()
	var mat := _display_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("source_tex", _sub_viewport.get_texture())

	_gradient_texture = GradientTexture2D.new()
	_gradient_texture.fill = GradientTexture2D.FILL_LINEAR
	_gradient_texture.gradient = Gradient.new()
	_gradient_rect.texture = _gradient_texture
	_gradient_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_gradient_rect.stretch_mode = TextureRect.STRETCH_SCALE
	_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	if settings:
		settings.changed.connect(_apply_led_settings)
	if text_style:
		text_style.changed.connect(_apply_text_style)
	if background:
		background.changed.connect(_apply_background)
	_apply_text_style()
	_apply_background()
	_text_animator.setup(_source_label, animation)
	_text_animator.set_raw_text(text)
	_signal_player.setup(_signal_graphic, _signal_left_rect, _signal_right_rect, _source_label, _text_animator, _siren_player)
	_signal_player.preset_activated.connect(func(preset: SignalPreset) -> void: preset_activated.emit(preset))
	_signal_player.preset_deactivated.connect(func() -> void: preset_deactivated.emit())
	resized.connect(_on_resized)
	_on_resized()
	_apply_led_settings()


func play() -> void:
	_text_animator.play()


func pause() -> void:
	_text_animator.pause()


func stop() -> void:
	_text_animator.stop()


func activate_preset(preset: SignalPreset, pattern: SignalPreset.BlinkPattern) -> void:
	_signal_player.activate(preset, pattern, text)


func deactivate_preset() -> void:
	_signal_player.deactivate()


func get_active_preset() -> SignalPreset:
	return _signal_player.preset if _signal_player.active else null


func set_siren_volume_db(db: float) -> void:
	_siren_player.volume_db = db


func _on_resized() -> void:
	if size.x < 1.0 or size.y < 1.0:
		return
	_sub_viewport.size = Vector2i(size)
	_background_layer.size = size
	_solid_rect.size = size
	_gradient_rect.size = size
	_image_rect.size = size
	_signal_graphic.size = size
	_text_animator.set_viewport_size(size)
	var mat := _display_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("rect_size", size)


func _apply_led_settings() -> void:
	if not settings:
		return
	var mat := _display_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("mask_enabled", settings.mask_enabled)
		mat.set_shader_parameter("dot_shape", settings.dot_shape)
		mat.set_shader_parameter("dot_radius_px", settings.dot_size)
		mat.set_shader_parameter("dot_spacing_px", settings.dot_spacing)
		mat.set_shader_parameter("blur_amount", settings.blur)
		mat.set_shader_parameter("brightness", settings.brightness)
		mat.set_shader_parameter("gap_color", settings.gap_color)
	_source_label.add_theme_color_override("default_color", settings.text_color)
	if _world_environment.environment:
		_world_environment.environment.glow_enabled = settings.glow_enabled
		_world_environment.environment.glow_strength = settings.glow_strength


func _apply_background() -> void:
	if not background or not is_node_ready():
		return
	var mode := background.mode
	_solid_rect.visible = mode == BackgroundSettings.Mode.SOLID or mode == BackgroundSettings.Mode.TRUE_BLACK
	_gradient_rect.visible = mode == BackgroundSettings.Mode.GRADIENT
	_image_rect.visible = mode == BackgroundSettings.Mode.IMAGE

	if mode == BackgroundSettings.Mode.TRUE_BLACK:
		_solid_rect.color = Color.BLACK
	elif mode == BackgroundSettings.Mode.SOLID:
		_solid_rect.color = background.solid_color
	elif mode == BackgroundSettings.Mode.GRADIENT:
		var angle_rad := deg_to_rad(background.gradient_angle)
		var dir := Vector2(cos(angle_rad), sin(angle_rad))
		_gradient_texture.gradient.set_color(0, background.gradient_color_a)
		_gradient_texture.gradient.set_color(1, background.gradient_color_b)
		_gradient_texture.fill_from = Vector2(0.5, 0.5) - dir * 0.5
		_gradient_texture.fill_to = Vector2(0.5, 0.5) + dir * 0.5
	elif mode == BackgroundSettings.Mode.IMAGE:
		_apply_background_image()

	_background_layer.modulate.a = background.opacity


func _apply_background_image() -> void:
	if background.image_path.is_empty() or background.image_path == _loaded_image_path:
		return
	var img := Image.new()
	if img.load(background.image_path) == OK:
		_image_rect.texture = ImageTexture.create_from_image(img)
		_loaded_image_path = background.image_path


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
