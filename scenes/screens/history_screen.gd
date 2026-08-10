class_name HistoryScreen
extends Control

@onready var _card_grid: GridContainer = %CardGrid
@onready var _empty_label: Label = %EmptyLabel


func _ready() -> void:
	AppSettings.history_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for child in _card_grid.get_children():
		child.queue_free()
	var entries: Array[Dictionary] = AppSettings.get_history()
	_empty_label.visible = entries.is_empty()
	for entry in entries:
		var id: String = entry.get("id", "")
		var type: String = entry.get("type", "")
		var date_str := _format_date(entry.get("activated_at", 0))
		if type == "signal":
			var preset := PresetRegistry.find_signal(id)
			if preset:
				var card := ModeCardFactory.for_signal_preset(preset)
				card.set_title("%s — %s" % [preset.display_name, date_str])
				_card_grid.add_child(card)
		elif type == "thematic":
			var preset := PresetRegistry.find_thematic(id)
			if preset:
				var card := ModeCardFactory.for_thematic_preset(preset)
				card.set_title("%s — %s" % [preset.display_name, date_str])
				_card_grid.add_child(card)


func _format_date(unix_time: int) -> String:
	var d := Time.get_datetime_dict_from_unix_time(unix_time)
	return "%02d.%02d %02d:%02d" % [d.day, d.month, d.hour, d.minute]
