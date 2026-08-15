class_name ModeCardFactory
extends RefCounted

const MODE_CARD_SCENE: PackedScene = preload("res://scenes/components/ModeCard.tscn")
const PRESET_DETAIL_SCENE: PackedScene = preload("res://scenes/screens/PresetDetailScreen.tscn")
const MESSAGE_DETAIL_SCENE: PackedScene = preload("res://scenes/screens/MessageDetailScreen.tscn")

const SUBTITLES := {
	"police": "Сигнальные огни",
	"ambulance": "Медицинский сигнал",
	"firetruck": "Красный маяк",
	"warning": "Предупреждающий свет",
	"sos": "Азбука Морзе",
	"taxi": "Городской сигнал",
	"security": "Охранный режим",
	"party": "Реакция на звук",
	"love": "Световое сообщение",
	"birthday": "Праздничная анимация",
	"christmas": "Зимняя палитра",
}

const CARD_VISUAL_IDS := {
	"police": "police",
	"ambulance": "ambulance",
	"firetruck": "fire",
	"warning": "warning",
	"sos": "sos",
	"taxi": "taxi",
	"security": "security",
	"party": "party",
	"love": "love",
	"birthday": "birthday",
	"christmas": "christmas",
}


static func for_signal_preset(preset: SignalPreset) -> ModeCard:
	var card: ModeCard = MODE_CARD_SCENE.instantiate()
	card.set_title(preset.display_name)
	card.set_subtitle(SUBTITLES.get(preset.id, "Сигнальный режим"))
	card.set_visual_id(CARD_VISUAL_IDS.get(preset.id, preset.id))
	card.accent_color = preset.color_a
	card.card_pressed.connect(func() -> void: Router.push(PRESET_DETAIL_SCENE, {"preset": preset}))
	return card


static func for_thematic_preset(preset: ThematicPreset) -> ModeCard:
	var card: ModeCard = MODE_CARD_SCENE.instantiate()
	card.set_title(preset.display_name)
	card.set_subtitle(SUBTITLES.get(preset.id, "Тематическое сообщение"))
	card.set_visual_id(CARD_VISUAL_IDS.get(preset.id, preset.id))
	var accent: Color = preset.palette.colors[0] if preset.palette and preset.palette.colors.size() > 0 else Color.WHITE
	card.accent_color = accent
	card.card_pressed.connect(func() -> void: Router.push(MESSAGE_DETAIL_SCENE, {"preset": preset}))
	return card
