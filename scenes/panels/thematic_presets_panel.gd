class_name ThematicPresetsPanel
extends PanelContainer

signal preset_selected(preset: ThematicPreset)
signal stop_requested

const PRESET_PATHS := [
	"res://resources/presets_thematic/party.tres",
	"res://resources/presets_thematic/love.tres",
	"res://resources/presets_thematic/birthday.tres",
	"res://resources/presets_thematic/christmas.tres",
]

@onready var _preset_grid: GridContainer = %PresetGrid
@onready var _stop_button: Button = %StopButton


func _ready() -> void:
	for path in PRESET_PATHS:
		var preset: ThematicPreset = load(path)
		var button := Button.new()
		button.text = preset.display_name
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void: preset_selected.emit(preset))
		_preset_grid.add_child(button)

	_stop_button.pressed.connect(func() -> void: stop_requested.emit())
