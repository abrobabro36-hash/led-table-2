extends Node

signal stack_changed(depth: int)

var _host: Control
var _stack: Array[Control] = []


func register_host(host: Control) -> void:
	_host = host


func push(scene: PackedScene, data: Dictionary = {}) -> void:
	var screen: Control = scene.instantiate()
	_host.add_child(screen)
	if screen.has_method("setup"):
		screen.setup(data)
	for child in _host.get_children():
		child.visible = child == screen
	_stack.append(screen)
	stack_changed.emit(_stack.size())


func pop() -> void:
	if _stack.size() <= 1:
		return
	var top: Control = _stack.pop_back()
	top.queue_free()
	var new_top: Control = _stack[-1]
	new_top.visible = true
	stack_changed.emit(_stack.size())


## Clears the whole stack and pushes a new root screen — used by the bottom
## tab bar so switching tabs never grows the back-navigation stack.
func switch_tab(scene: PackedScene, data: Dictionary = {}) -> void:
	for screen in _stack:
		screen.queue_free()
	_stack.clear()
	push(scene, data)


func stack_depth() -> int:
	return _stack.size()
