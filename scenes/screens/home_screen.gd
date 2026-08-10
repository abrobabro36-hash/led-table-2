class_name HomeScreen
extends Control

const MODE_CARD_SCENE: PackedScene = preload("res://scenes/components/ModeCard.tscn")
const PRESET_DETAIL_SCENE: PackedScene = preload("res://scenes/screens/PresetDetailScreen.tscn")
const MESSAGE_DETAIL_SCENE: PackedScene = preload("res://scenes/screens/MessageDetailScreen.tscn")
const ADVANCED_EDITOR_SCENE: PackedScene = preload("res://scenes/screens/AdvancedEditorScreen.tscn")
const ADVANCED_EDITOR_ACCENT := Color(0.298, 0.549, 1.0)

@onready var _card_grid: GridContainer = %CardGrid


func _ready() -> void:
	for preset in PresetRegistry.list_signal_presets():
		_card_grid.add_child(_make_card(preset.display_name, preset.color_a, func() -> void:
			Router.push(PRESET_DETAIL_SCENE, {"preset": preset})
		))
	for preset in PresetRegistry.list_thematic_presets():
		var accent: Color = preset.palette.colors[0] if preset.palette and preset.palette.colors.size() > 0 else Color.WHITE
		_card_grid.add_child(_make_card(preset.display_name, accent, func() -> void:
			Router.push(MESSAGE_DETAIL_SCENE, {"preset": preset})
		))
	_card_grid.add_child(_make_card("Расширенный редактор", ADVANCED_EDITOR_ACCENT, func() -> void:
		Router.push(ADVANCED_EDITOR_SCENE)
	))


func _make_card(title: String, accent: Color, on_press: Callable) -> ModeCard:
	var card: ModeCard = MODE_CARD_SCENE.instantiate()
	card.set_title(title)
	card.accent_color = accent
	card.card_pressed.connect(on_press)
	return card
