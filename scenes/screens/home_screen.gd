class_name HomeScreen
extends Control

const ADVANCED_EDITOR_SCENE: PackedScene = preload("res://scenes/screens/AdvancedEditorScreen.tscn")
const ADVANCED_EDITOR_ACCENT := Color(0.298, 0.549, 1.0)

@onready var _card_grid: GridContainer = %CardGrid


func _ready() -> void:
	for preset in PresetRegistry.list_signal_presets():
		_card_grid.add_child(ModeCardFactory.for_signal_preset(preset))
	for preset in PresetRegistry.list_thematic_presets():
		_card_grid.add_child(ModeCardFactory.for_thematic_preset(preset))

	var editor_card: ModeCard = ModeCardFactory.MODE_CARD_SCENE.instantiate()
	editor_card.set_title("Расширенный редактор")
	editor_card.set_icon("🎛️")
	editor_card.accent_color = ADVANCED_EDITOR_ACCENT
	editor_card.card_pressed.connect(func() -> void: Router.push(ADVANCED_EDITOR_SCENE))
	_card_grid.add_child(editor_card)
