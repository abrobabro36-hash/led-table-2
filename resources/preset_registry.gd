class_name PresetRegistry
extends RefCounted

const SIGNAL_PRESET_PATHS := [
	"res://resources/presets/police.tres",
	"res://resources/presets/ambulance.tres",
	"res://resources/presets/firetruck.tres",
	"res://resources/presets/warning.tres",
	"res://resources/presets/sos.tres",
	"res://resources/presets/taxi.tres",
	"res://resources/presets/security.tres",
]

const THEMATIC_PRESET_PATHS := [
	"res://resources/presets_thematic/party.tres",
	"res://resources/presets_thematic/love.tres",
	"res://resources/presets_thematic/birthday.tres",
	"res://resources/presets_thematic/christmas.tres",
]


static func list_signal_presets() -> Array[SignalPreset]:
	var result: Array[SignalPreset] = []
	for path in SIGNAL_PRESET_PATHS:
		result.append(load(path))
	return result


static func list_thematic_presets() -> Array[ThematicPreset]:
	var result: Array[ThematicPreset] = []
	for path in THEMATIC_PRESET_PATHS:
		result.append(load(path))
	return result


static func find_signal(id: String) -> SignalPreset:
	for path in SIGNAL_PRESET_PATHS:
		var preset: SignalPreset = load(path)
		if preset.id == id:
			return preset
	return null


static func find_thematic(id: String) -> ThematicPreset:
	for path in THEMATIC_PRESET_PATHS:
		var preset: ThematicPreset = load(path)
		if preset.id == id:
			return preset
	return null
