@tool 
class_name FootstepsSurfaceAudio extends Resource

@export_group("Clip Landing")
@export var landing_clips: Array[AudioStream]

@export_group("Clips List")
@export var clips: Array[AudioStream]

@export_group("Units")
@export var min_unit_size: float = 0.30:
	get: return min_unit_size
	set(value):
		min_unit_size = clamp(value, 0.0, value)

@export var max_unit_size: float = 0.60:
	get: return max_unit_size
	set(value):
		max_unit_size = clamp(value, 0.0, value)

@export_group("FX")
@export_subgroup("Panner")
@export var pan_range: float = 0.1:
	get: return pan_range
	set(value):
		pan_range = clamp(value, 0.0, 1.0)

@export_subgroup("Pitch")
@export var min_pitch_range: float = 0.9:
	get: return min_pitch_range
	set(value):
		min_pitch_range = clamp(value, 0.01, value)

@export var max_pitch_range: float = 1.1:
	get: return max_pitch_range
	set(value):
		max_pitch_range = value
