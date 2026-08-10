extends Node

signal projects_changed

const PROJECTS_DIR := "user://projects/"
const AUTOSAVE_PATH := "user://autosave.tres"


func list_projects() -> Array[Project]:
	var result: Array[Project] = []
	var dir := DirAccess.open(PROJECTS_DIR)
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var project := load(PROJECTS_DIR + file_name) as Project
			if project:
				result.append(project)
		file_name = dir.get_next()
	dir.list_dir_end()
	result.sort_custom(func(a: Project, b: Project) -> bool: return a.modified_at > b.modified_at)
	return result


func create_project(snapshot: Project, display_name: String) -> Project:
	var now := int(Time.get_unix_time_from_system())
	snapshot.id = _new_id()
	snapshot.project_name = display_name
	snapshot.created_at = now
	snapshot.modified_at = now
	_write(snapshot)
	projects_changed.emit()
	return snapshot


func duplicate_project(project: Project) -> Project:
	var copy: Project = project.duplicate(true)
	var now := int(Time.get_unix_time_from_system())
	copy.id = _new_id()
	copy.project_name = project.project_name + " (копия)"
	copy.created_at = now
	copy.modified_at = now
	_write(copy)
	projects_changed.emit()
	return copy


func delete_project(project: Project) -> void:
	var path := _path_for(project.id)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	projects_changed.emit()


func touch_project(project: Project) -> void:
	project.modified_at = int(Time.get_unix_time_from_system())
	_write(project)
	projects_changed.emit()


func autosave(snapshot: Project) -> void:
	ResourceSaver.save(snapshot, AUTOSAVE_PATH)


func load_autosave() -> Project:
	if FileAccess.file_exists(AUTOSAVE_PATH):
		return load(AUTOSAVE_PATH) as Project
	return null


func _write(project: Project) -> void:
	DirAccess.make_dir_recursive_absolute(PROJECTS_DIR)
	ResourceSaver.save(project, _path_for(project.id))


func _path_for(id: String) -> String:
	return PROJECTS_DIR + id + ".tres"


func _new_id() -> String:
	return "proj_%d_%d" % [Time.get_unix_time_from_system(), randi() % 1000000]
