class_name AppShell
extends Control

const HOME_SCENE: PackedScene = preload("res://scenes/screens/HomeScreen.tscn")
const FAVORITES_SCENE: PackedScene = preload("res://scenes/screens/FavoritesScreen.tscn")
const HISTORY_SCENE: PackedScene = preload("res://scenes/screens/HistoryScreen.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://scenes/screens/SettingsScreen.tscn")

@onready var _screen_host: Control = %ScreenHost
@onready var _tab_bar: BottomTabBar = %BottomTabBar

var _tab_scenes: Array[PackedScene] = [HOME_SCENE, FAVORITES_SCENE, HISTORY_SCENE, SETTINGS_SCENE]
var _active_tab_index: int = 0


func _ready() -> void:
	Router.register_host(_screen_host)
	Router.stack_changed.connect(_on_stack_changed)
	_tab_bar.tab_selected.connect(_on_tab_selected)
	Router.switch_tab(HOME_SCENE)


func _on_tab_selected(index: int) -> void:
	_active_tab_index = index
	Router.switch_tab(_tab_scenes[index])


func _on_stack_changed(depth: int) -> void:
	_tab_bar.visible = depth <= 1


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_back()


func _handle_back() -> void:
	if Router.stack_depth() > 1:
		Router.pop()
	elif _active_tab_index != 0:
		_active_tab_index = 0
		_tab_bar.set_active(0)
		Router.switch_tab(HOME_SCENE)
	else:
		get_tree().quit()
