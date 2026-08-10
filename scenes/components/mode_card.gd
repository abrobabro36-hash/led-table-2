class_name ModeCard
extends Button

signal card_pressed

@export var accent_color: Color = Color.WHITE:
	set(value):
		accent_color = value
		if is_node_ready():
			_apply_accent()

@onready var _accent_rect: ColorRect = %AccentRect
@onready var _title_label: Label = %TitleLabel

var _pending_title: String = ""


func _ready() -> void:
	pressed.connect(func() -> void: card_pressed.emit())
	_apply_accent()
	_title_label.text = _pending_title


## Safe to call before the card enters the tree (e.g. right after
## instantiate()) — the value is applied once @onready fields are ready.
func set_title(value: String) -> void:
	_pending_title = value
	if is_node_ready():
		_title_label.text = value


func _apply_accent() -> void:
	_accent_rect.color = accent_color
