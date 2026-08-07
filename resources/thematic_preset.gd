class_name ThematicPreset
extends Resource

enum Movement { FLOAT_UP, TWINKLE_FALL }

@export var id: String = ""
@export var display_name: String = ""
@export var palette: AppColorPalette
@export var symbols: Array[String] = []
@export var movement: Movement = Movement.FLOAT_UP
@export_range(0.1, 3.0, 0.05) var spawn_interval: float = 0.5
@export_range(0.5, 6.0, 0.1) var particle_lifetime: float = 2.5
@export_range(12.0, 96.0, 1.0) var particle_font_size: float = 40.0
@export var reacts_to_audio: bool = false
@export_range(0.3, 8.0, 0.1) var decorative_duration: float = 4.0
