extends Node

signal favorites_changed
signal history_changed
signal settings_changed

const SAVE_PATH := "user://app_settings.tres"
const MAX_HISTORY := 20

var data: AppSettingsData


func _ready() -> void:
	data = _load()
	if data.keep_screen_on:
		DisplayServer.screen_set_keep_on(true)


func is_favorite(id: String) -> bool:
	return id in data.favorite_ids


func toggle_favorite(id: String) -> void:
	if id in data.favorite_ids:
		data.favorite_ids.erase(id)
	else:
		data.favorite_ids.append(id)
	_save()
	favorites_changed.emit()


func record_activation(type: String, id: String) -> void:
	for entry in data.history:
		if entry.get("id") == id and entry.get("type") == type:
			data.history.erase(entry)
			break
	data.history.push_front({"type": type, "id": id, "activated_at": int(Time.get_unix_time_from_system())})
	if data.history.size() > MAX_HISTORY:
		data.history.resize(MAX_HISTORY)
	_save()
	history_changed.emit()


func get_history() -> Array[Dictionary]:
	return data.history


func set_auto_start_last_mode(enabled: bool) -> void:
	data.auto_start_last_mode = enabled
	_save()
	settings_changed.emit()


func set_keep_screen_on(enabled: bool) -> void:
	data.keep_screen_on = enabled
	DisplayServer.screen_set_keep_on(enabled)
	_save()
	settings_changed.emit()


func set_vibration_enabled(enabled: bool) -> void:
	data.vibration_enabled = enabled
	_save()
	settings_changed.emit()


func set_led_density(density: String) -> void:
	data.led_density = density
	_save()
	settings_changed.emit()


func set_theme_variant(variant: String) -> void:
	data.theme_variant = variant
	_save()
	settings_changed.emit()


func _load() -> AppSettingsData:
	if FileAccess.file_exists(SAVE_PATH):
		var loaded := load(SAVE_PATH) as AppSettingsData
		if loaded:
			return loaded
	return AppSettingsData.new()


func _save() -> void:
	ResourceSaver.save(data, SAVE_PATH)
