class_name MessageDetailScreen
extends Control

@onready var _back_button: Button = %BackButton
@onready var _title_label: Label = %TitleLabel

var _preset: ThematicPreset


func setup(data: Dictionary) -> void:
	_preset = data.get("preset")
	if is_node_ready():
		_apply_preset()


func _ready() -> void:
	_back_button.pressed.connect(func() -> void: Router.pop())
	_apply_preset()


func _apply_preset() -> void:
	if _preset:
		_title_label.text = _preset.display_name
