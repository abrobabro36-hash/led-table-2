class_name SignalPreset
extends Resource

enum BlinkPattern { SYNC, ALTERNATE, WIG_WAG, SOS_MORSE }
enum SirenType { NONE, WAIL, YELP, TWO_TONE, SOS_BEEP }

@export var id: String = ""
@export var display_name: String = ""
@export var color_a: Color = Color.WHITE
@export var color_b: Color = Color.WHITE
@export var available_patterns: Array[BlinkPattern] = [BlinkPattern.SYNC]
@export var default_pattern: BlinkPattern = BlinkPattern.SYNC
@export var siren_type: SirenType = SirenType.NONE
@export var has_volume_control: bool = false
@export_range(0.3, 8.0, 0.1) var signal_duration: float = 1.5
@export_range(0.1, 3.0, 0.05) var blink_speed: float = 1.0
