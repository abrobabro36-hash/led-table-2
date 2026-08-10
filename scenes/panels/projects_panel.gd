class_name ProjectsPanel
extends PanelContainer

@export var led_board: LedBoard
@export var text_panel: TextEditorPanel
@export var background_panel: BackgroundPanel

@onready var _save_button: Button = %SaveButton
@onready var _empty_label: Label = %EmptyLabel
@onready var _project_list: VBoxContainer = %ProjectList
@onready var _save_dialog: ConfirmationDialog = %SaveDialog
@onready var _save_name_input: LineEdit = %SaveNameInput
@onready var _delete_dialog: ConfirmationDialog = %DeleteDialog

var _pending_delete: Project


func _ready() -> void:
	_save_button.pressed.connect(_on_save_pressed)
	_save_dialog.confirmed.connect(_on_save_confirmed)
	_delete_dialog.confirmed.connect(_on_delete_confirmed)
	ProjectManager.projects_changed.connect(_refresh_list)
	_refresh_list()


func _on_save_pressed() -> void:
	_save_name_input.text = _default_name_for(led_board.text)
	_save_dialog.popup_centered()


func _on_save_confirmed() -> void:
	var display_name := _save_name_input.text.strip_edges()
	if display_name.is_empty():
		display_name = _default_name_for(led_board.text)
	var snapshot := Project.capture(led_board.text, led_board.text_style, led_board.animation, led_board.settings, led_board.background)
	ProjectManager.create_project(snapshot, display_name)


func _refresh_list() -> void:
	for child in _project_list.get_children():
		child.queue_free()
	var projects := ProjectManager.list_projects()
	_empty_label.visible = projects.is_empty()
	for project in projects:
		_project_list.add_child(_build_row(project))


func _build_row(project: Project) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var load_button := Button.new()
	load_button.text = "%s — %s" % [project.project_name, _format_date(project.modified_at)]
	load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_button.clip_text = true
	load_button.pressed.connect(_on_load_pressed.bind(project))
	row.add_child(load_button)

	var duplicate_button := Button.new()
	duplicate_button.text = "Копия"
	duplicate_button.pressed.connect(func() -> void: ProjectManager.duplicate_project(project))
	row.add_child(duplicate_button)

	var delete_button := Button.new()
	delete_button.text = "Удалить"
	delete_button.pressed.connect(_on_delete_pressed.bind(project))
	row.add_child(delete_button)

	return row


func _on_load_pressed(project: Project) -> void:
	project.apply_to(led_board.text_style, led_board.animation, led_board.settings, led_board.background)
	led_board.text = project.text
	text_panel.set_text(project.text)
	text_panel.sync_ui()
	background_panel.sync_ui()
	ProjectManager.touch_project(project)


func _on_delete_pressed(project: Project) -> void:
	_pending_delete = project
	_delete_dialog.dialog_text = "Удалить проект «%s»? Это действие нельзя отменить." % project.project_name
	_delete_dialog.popup_centered()


func _on_delete_confirmed() -> void:
	if _pending_delete:
		ProjectManager.delete_project(_pending_delete)
		_pending_delete = null


func _default_name_for(text: String) -> String:
	var trimmed := text.strip_edges()
	var base := trimmed.substr(0, 24) if not trimmed.is_empty() else "Без названия"
	return "%s · %s" % [base, _format_date(int(Time.get_unix_time_from_system()))]


func _format_date(unix_time: int) -> String:
	var d := Time.get_datetime_dict_from_unix_time(unix_time)
	return "%02d.%02d.%04d %02d:%02d" % [d.day, d.month, d.year, d.hour, d.minute]
