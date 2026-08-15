class_name HomeScreen
extends Control

const ADVANCED_EDITOR_SCENE: PackedScene = preload("res://scenes/screens/AdvancedEditorScreen.tscn")
const ADVANCED_EDITOR_ACCENT := Color(0.298, 0.549, 1.0)

@onready var _card_grid: GridContainer = %CardGrid
@onready var _editor_card_host: VBoxContainer = %EditorCardHost
@onready var _count_label: Label = %CountLabel


func _ready() -> void:
	for preset in PresetRegistry.list_signal_presets():
		_card_grid.add_child(ModeCardFactory.for_signal_preset(preset))
	for preset in PresetRegistry.list_thematic_presets():
		_card_grid.add_child(ModeCardFactory.for_thematic_preset(preset))

	var editor_card: ModeCard = ModeCardFactory.MODE_CARD_SCENE.instantiate()
	editor_card.set_title("Расширенный редактор")
	editor_card.set_subtitle("Соберите своё табло")
	editor_card.set_visual_id("advanced_editor")
	editor_card.accent_color = ADVANCED_EDITOR_ACCENT
	editor_card.card_pressed.connect(func() -> void: Router.push(ADVANCED_EDITOR_SCENE))
	_editor_card_host.add_child(editor_card)
	_count_label.text = "%d режимов" % (_card_grid.get_child_count() + 1)
	resized.connect(_update_grid_columns)
	call_deferred("_update_grid_columns")


func _update_grid_columns() -> void:
	# Phone portrait remains a strict two-column composition. Wider tablet
	# layouts reuse the existing shared responsive policy rather than a second
	# Home implementation.
	_card_grid.columns = ResponsiveLayout.home_columns(size.x)
