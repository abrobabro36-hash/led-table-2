class_name Project
extends Resource

@export var id: String = ""
@export var project_name: String = ""
@export var created_at: int = 0
@export var modified_at: int = 0
@export var text: String = ""
@export var text_style: TextStyle
@export var animation: AnimationSettings
@export var led_settings: LedSettings
@export var background: BackgroundSettings


static func capture(p_text: String, p_text_style: TextStyle, p_animation: AnimationSettings, p_led_settings: LedSettings, p_background: BackgroundSettings) -> Project:
	var project := Project.new()
	project.text = p_text
	project.text_style = p_text_style.duplicate(true)
	project.animation = p_animation.duplicate(true)
	project.led_settings = p_led_settings.duplicate(true)
	project.background = p_background.duplicate(true)
	return project


## Copies this project's saved values onto the live scene's resource instances,
## preserving their identity so panels holding the same references stay in sync.
func apply_to(target_text_style: TextStyle, target_animation: AnimationSettings, target_led_settings: LedSettings, target_background: BackgroundSettings) -> void:
	_copy_script_properties(text_style, target_text_style)
	_copy_script_properties(animation, target_animation)
	_copy_script_properties(led_settings, target_led_settings)
	_copy_script_properties(background, target_background)


static func _copy_script_properties(from: Resource, to: Resource) -> void:
	for prop in from.get_script().get_script_property_list():
		to.set(prop.name, from.get(prop.name))
