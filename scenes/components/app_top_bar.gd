class_name AppTopBar
extends HBoxContainer

signal back_pressed

@onready var _back_button: Button = %BackButton
@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _trailing: HBoxContainer = %Trailing


func _ready() -> void:
	_back_button.pressed.connect(func() -> void: back_pressed.emit())


func set_title(value: String) -> void:
	_title.text = value


func set_subtitle(value: String) -> void:
	_subtitle.text = value
	_subtitle.visible = not value.is_empty()


func set_back_visible(value: bool) -> void:
	_back_button.visible = value


func get_trailing_container() -> HBoxContainer:
	return _trailing

