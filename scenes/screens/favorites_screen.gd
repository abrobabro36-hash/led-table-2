class_name FavoritesScreen
extends Control

@onready var _card_grid: GridContainer = %CardGrid
@onready var _empty_label: Label = %EmptyLabel


func _ready() -> void:
	AppSettings.favorites_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for child in _card_grid.get_children():
		child.queue_free()
	var ids: Array[String] = AppSettings.data.favorite_ids
	_empty_label.visible = ids.is_empty()
	for id in ids:
		var signal_preset := PresetRegistry.find_signal(id)
		if signal_preset:
			_card_grid.add_child(ModeCardFactory.for_signal_preset(signal_preset))
			continue
		var thematic_preset := PresetRegistry.find_thematic(id)
		if thematic_preset:
			_card_grid.add_child(ModeCardFactory.for_thematic_preset(thematic_preset))
