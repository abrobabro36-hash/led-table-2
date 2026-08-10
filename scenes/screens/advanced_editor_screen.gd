class_name AdvancedEditorScreen
extends Control

@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_back_button.pressed.connect(func() -> void: Router.pop())
