class_name ModeCardFactory
extends RefCounted

const MODE_CARD_SCENE: PackedScene = preload("res://scenes/components/ModeCard.tscn")
const PRESET_DETAIL_SCENE: PackedScene = preload("res://scenes/screens/PresetDetailScreen.tscn")
const MESSAGE_DETAIL_SCENE: PackedScene = preload("res://scenes/screens/MessageDetailScreen.tscn")

const ICONS := {
	"police": "🚔",
	"ambulance": "🚑",
	"firetruck": "🚒",
	"warning": "⚠️",
	"sos": "🆘",
	"taxi": "🚕",
	"security": "🛡️",
	"party": "🎉",
	"love": "❤️",
	"birthday": "🎂",
	"christmas": "❄️",
}
const DEFAULT_ICON := "🔷"


static func for_signal_preset(preset: SignalPreset) -> ModeCard:
	var card: ModeCard = MODE_CARD_SCENE.instantiate()
	card.set_title(preset.display_name)
	card.set_icon(ICONS.get(preset.id, DEFAULT_ICON))
	card.accent_color = preset.color_a
	card.card_pressed.connect(func() -> void: Router.push(PRESET_DETAIL_SCENE, {"preset": preset}))
	return card


static func for_thematic_preset(preset: ThematicPreset) -> ModeCard:
	var card: ModeCard = MODE_CARD_SCENE.instantiate()
	card.set_title(preset.display_name)
	card.set_icon(ICONS.get(preset.id, DEFAULT_ICON))
	var accent: Color = preset.palette.colors[0] if preset.palette and preset.palette.colors.size() > 0 else Color.WHITE
	card.accent_color = accent
	card.card_pressed.connect(func() -> void: Router.push(MESSAGE_DETAIL_SCENE, {"preset": preset}))
	return card
