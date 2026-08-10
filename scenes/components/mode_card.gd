class_name ModeCard
extends Button

signal card_pressed

@export var accent_color: Color = Color.WHITE:
	set(value):
		accent_color = value
		if is_node_ready():
			_apply_accent()

@onready var _icon_panel: PanelContainer = %IconPanel
@onready var _icon_label: Label = %IconLabel
@onready var _title_label: Label = %TitleLabel

var _pending_title: String = ""
var _pending_icon: String = "🔷"


func _ready() -> void:
	pressed.connect(func() -> void: card_pressed.emit())
	_apply_accent()
	_title_label.text = _pending_title
	_icon_label.text = _pending_icon


## Safe to call before the card enters the tree (e.g. right after
## instantiate()) — the value is applied once @onready fields are ready.
func set_title(value: String) -> void:
	_pending_title = value
	if is_node_ready():
		_title_label.text = value


func set_icon(emoji: String) -> void:
	_pending_icon = emoji
	if is_node_ready():
		_icon_label.text = emoji


func _apply_accent() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = accent_color
	box.corner_radius_top_left = 14
	box.corner_radius_top_right = 14
	box.corner_radius_bottom_left = 14
	box.corner_radius_bottom_right = 14
	_icon_panel.add_theme_stylebox_override("panel", box)
