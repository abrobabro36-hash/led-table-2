class_name ModeCard
extends Button

signal card_pressed

@export var accent_color: Color = Color(0.2, 0.55, 1.0):
	set(value):
		accent_color = value
		if is_node_ready():
			_apply_presentation()

@onready var _art: PanelContainer = %Art
@onready var _preview_texture: TextureRect = %PreviewTexture
@onready var _title_label: Label = %TitleLabel
@onready var _subtitle_label: Label = %SubtitleLabel

var _pending_title := ""
var _pending_subtitle := ""
var _pending_visual_id := ""

const MODE_TEXTURES: Dictionary = {
	"police": preload("res://assets/ui/mode_cards/police.png"),
	"ambulance": preload("res://assets/ui/mode_cards/ambulance.png"),
	"fire": preload("res://assets/ui/mode_cards/fire.png"),
	"warning": preload("res://assets/ui/mode_cards/warning.png"),
	"sos": preload("res://assets/ui/mode_cards/sos.png"),
	"taxi": preload("res://assets/ui/mode_cards/taxi.png"),
	"security": preload("res://assets/ui/mode_cards/security.png"),
	"party": preload("res://assets/ui/mode_cards/party.png"),
	"love": preload("res://assets/ui/mode_cards/love.png"),
	"birthday": preload("res://assets/ui/mode_cards/birthday.png"),
	"christmas": preload("res://assets/ui/mode_cards/christmas.png"),
	"advanced_editor": preload("res://assets/ui/mode_cards/advanced_editor.png"),
}

const PREVIEW_ASPECT_RATIO := 1.5
const OUTER_HORIZONTAL_INSET := 24.0
const MIN_PREVIEW_HEIGHT := 106.0
const CARD_TEXT_AND_PADDING_HEIGHT := 92.0

var _last_preview_height := -1.0


func _ready() -> void:
	pressed.connect(func() -> void: card_pressed.emit())
	_title_label.text = _pending_title
	_subtitle_label.text = _pending_subtitle
	_apply_presentation()
	resized.connect(_update_card_geometry)
	call_deferred("_update_card_geometry")


## Kept for ModeCardFactory compatibility. The approved mode image is the
## visual preview; legacy icon values are not rendered as a second visual.
func set_icon(_value: String) -> void:
	pass


func set_title(value: String) -> void:
	_pending_title = value
	if is_node_ready():
		_title_label.text = value


func set_subtitle(value: String) -> void:
	_pending_subtitle = value
	if is_node_ready():
		_subtitle_label.text = value


func set_visual_id(value: String) -> void:
	_pending_visual_id = value
	if is_node_ready():
		_apply_presentation()


func _apply_presentation() -> void:
	# Keep the card as one dark premium surface. Mode identity belongs to the
	# approved preview; the card perimeter stays neutral and quiet.
	var surface := _build_card_surface(Color(0.045, 0.064, 0.087, 1), 0.56)
	add_theme_stylebox_override("normal", surface)
	var hover := _build_card_surface(Color(0.06, 0.08, 0.106, 1), 0.72)
	add_theme_stylebox_override("hover", hover)
	var pressed_box := _build_card_surface(
		Color(accent_color.r * 0.13, accent_color.g * 0.13, accent_color.b * 0.13, 1),
		0.82
	)
	add_theme_stylebox_override("pressed", pressed_box)

	var art_box := StyleBoxFlat.new()
	art_box.bg_color = Color(0.02, 0.029, 0.041, 1)
	art_box.border_width_left = 1
	art_box.border_width_top = 1
	art_box.border_width_right = 1
	art_box.border_width_bottom = 1
	art_box.border_color = Color(0.36, 0.42, 0.5, 0.28)
	art_box.corner_radius_top_left = 12
	art_box.corner_radius_top_right = 12
	art_box.corner_radius_bottom_right = 12
	art_box.corner_radius_bottom_left = 12
	# The preview frame's inner box is 3:2 at the phone target, matching all
	# approved source images. This lets COVER fill the frame without a visible
	# letterbox or a crop of the primary composition.
	art_box.content_margin_left = 1
	art_box.content_margin_top = 1
	art_box.content_margin_right = 1
	art_box.content_margin_bottom = 1
	_art.add_theme_stylebox_override("panel", art_box)
	_preview_texture.texture = MODE_TEXTURES.get(_pending_visual_id, null) as Texture2D


func _update_card_geometry() -> void:
	# All approved mode-card assets are 3:2. Keep the preview frame at that
	# ratio as the grid grows so COVER remains a tiny edge trim rather than
	# cutting text-heavy artwork into a horizontal banner.
	var available_width := maxf(size.x - OUTER_HORIZONTAL_INSET, 0.0)
	var preview_height := maxf(MIN_PREVIEW_HEIGHT, roundf(available_width / PREVIEW_ASPECT_RATIO))
	if is_equal_approx(preview_height, _last_preview_height):
		return
	_last_preview_height = preview_height
	_art.custom_minimum_size = Vector2(0.0, preview_height)
	custom_minimum_size = Vector2(0.0, preview_height + CARD_TEXT_AND_PADDING_HEIGHT)


func _build_card_surface(background: Color, border_opacity: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.23, 0.28, 0.34, border_opacity)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style
