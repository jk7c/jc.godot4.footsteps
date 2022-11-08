@tool
class_name Footsteps extends Node3D

# Audio player.
var audio_player: AudioStreamPlayer3D = null:
	get: return audio_player
	set(value):
		audio_player = value

var default_clips: FootstepsSurfaceAudio = null:
	get: return default_clips
	set(value):
		default_clips = value

# Surfaces.
const DEFAULT_SURFACE_META_ID:= "surface"

## Surface ID for metadata.
var surface_meta_id: String = DEFAULT_SURFACE_META_ID:
	get: return surface_meta_id
	set(value):
		if value == "":
			surface_meta_id = DEFAULT_SURFACE_META_ID
		else:
			surface_meta_id = value

@export_group("Audio")
@export_subgroup("Surface")
@export var surfaces: Array[FootstepsSurface]

# Surface interval.
@export_group("Step")

## Interval between each step.
@export var step_interval: float = 2.0:
	get: return step_interval
	set(value):
		step_interval = value

var bus_index: int = 1:
	get: return bus_index
	set(value):
		bus_index = value

var enable_pan: bool = false:
	get: return enable_pan
	set(value):
		enable_pan = value
		notify_property_list_changed()

## Index of the pan fx.
var pan_index: int = 0:
	get: return pan_index
	set(value):
		pan_index = value

## Enable pitch effect.
var enable_pitch: bool = false:
	get: return enable_pitch
	set(value):
		enable_pitch = value
		notify_property_list_changed()

## Index of the pitch fx.
var pitch_index: int = 1:
	get: return pitch_index
	set(value):
		pitch_index = value

# Step.
var _on_air_store: bool = false
var _step: float
var _distance_travelled: float

# Current clips.
var _current_landing_clip: AudioStream = null
var _current_surface_texture: Texture = null

# Nodes.
var _character: CharacterBody3D = null
var _Random:= RandomNumberGenerator.new()

var _default_surface: bool = true
var _physics_delta: float
var _pan_range: float
var _min_unit_size: float
var _max_unit_size: float
var _min_pitch_range: float
var _max_pitch_range: float
var _enable_panner: bool

func _enter_tree() -> void:
	_character = get_parent() as CharacterBody3D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_enable_panner = false
	_play()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_physics_delta = delta
	
	if _character == null:
		return
	
	if !_character.is_on_floor():
		_on_air_store = true
	
	if _character.is_on_floor() && _on_air_store:
		_on_landing()
		_on_air_store = false

	# Step.
	if _character.is_on_floor():
		_distance_travelled += _character.velocity.length() * delta
		if _distance_travelled > _step:
			_enable_panner = true
			_play()
			_distance_travelled = 0.0
			_step = step_interval

func _get_ground_texture() -> Texture:
	var slideCollision
	for i in _character.get_slide_collision_count():
		slideCollision = _character.get_slide_collision(i)
	
	if slideCollision == null:
		return null
	
	for i in slideCollision.get_collision_count():
		var collider = slideCollision.get_collider(i)
		if collider is PhysicsBody3D:
			if collider.has_meta(surface_meta_id):
				var meta: Texture = collider.get_meta(surface_meta_id, Texture)
				if meta != null:
					return meta
		
	return null

func _play() -> void:
	if audio_player == null:
		return
	
	_current_surface_texture = _get_ground_texture()
	if _current_surface_texture != null:
		_play_surface_clips()
	else:
		_default_surface = true
		_play_default_clips()

func _on_landing() -> void:
	if audio_player == null:
		return
	
	_enable_panner = false
	_play()
	_play_audio_player(_current_landing_clip)

func _play_audio_player(clip: AudioStream) -> void:
	audio_player.unit_size = _Random.randf_range(_min_unit_size, _max_unit_size)
	audio_player.stream = clip
	
	# Panner.
	if enable_pan:
		var fx: AudioEffectPanner = AudioServer.get_bus_effect(bus_index, pan_index) as AudioEffectPanner
		if fx != null:
			if _enable_panner:
				fx.pan = _pan_range - fx.pan - _pan_range
				if fx.pan == 0.0:
					fx.pan = _pan_range
			else:
				fx.pan = 0.0
	
	# Pitch.
	if enable_pitch:
		var fx: AudioEffectPitchShift = AudioServer.get_bus_effect(bus_index, pitch_index) as AudioEffectPitchShift
		if fx != null:
			fx.pitch_scale = _Random.randf_range(_min_pitch_range, _max_pitch_range)
	
	audio_player.play()

func _play_surface_clips() -> void:
	if surfaces.size() > 0:
		for surface in surfaces:
			if surface.exists(_current_surface_texture):
				_default_surface = false
				_min_unit_size = surface.min_unit_size
				_max_unit_size = surface.max_unit_size
				_pan_range = surface.pan_range
				_min_pitch_range = surface.min_pitch_range
				_max_pitch_range = surface.max_pitch_range
				
				if surface.landing_clips.size() > 0:
					_current_landing_clip = surface.landing_clips[
						_Random.randi_range(0, surface.landing_clips.size() - 1)
					]
				
				_play_audio_player(
					surface.clips[_Random.randi_range(0, surface.clips.size() - 1)]
				)
	else:
		_default_surface = true
		_play_default_clips()

func _play_default_clips() -> void:
	if default_clips == null:
		return
	
	_min_unit_size = default_clips.min_unit_size
	_max_unit_size = default_clips.max_unit_size
	_pan_range = default_clips.pan_range
	_min_pitch_range = default_clips.min_pitch_range
	_max_pitch_range = default_clips.max_pitch_range
	
	if default_clips.landing_clips.size() > 0:
		_current_landing_clip = default_clips.landing_clips[
			_Random.randi_range(0, default_clips.landing_clips.size() - 1)
		]
		
	_play_audio_player(
		default_clips.clips[_Random.randi_range(0, default_clips.clips.size() - 1)]
	)

func _get_property_list() -> Array:
	var ret:= Array()
	ret.push_back({name = "Footsteps", type=TYPE_NIL, usage=PROPERTY_USAGE_CATEGORY})
	
	ret.push_back({name = "Audio", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	
	ret.push_back({name = "Player", type=TYPE_NIL, usage=PROPERTY_USAGE_SUBGROUP})
	ret.push_back({name = "audio_player", type=TYPE_OBJECT, hint=PROPERTY_HINT_NODE_TYPE})
	
	ret.push_back({name = "Surface", type=TYPE_NIL, usage=PROPERTY_USAGE_SUBGROUP})
	ret.push_back({name = "surface_meta_id", type=TYPE_STRING_NAME})
	ret.push_back({name = "default_clips", type=TYPE_OBJECT, hint=PROPERTY_HINT_RESOURCE_TYPE, hint_string = "FootstepsSurfaceAudio"})
	
	ret.push_back({name = "FX", type=TYPE_NIL, usage=PROPERTY_USAGE_SUBGROUP})
	ret.push_back({name = "bus_index", type=TYPE_INT})
	ret.push_back({name = "enable_pan", type=TYPE_BOOL})
	if enable_pan:
		ret.push_back({name = "pan_index", type=TYPE_INT})
	
	ret.push_back({name = "enable_pitch", type=TYPE_BOOL})
	if enable_pitch:
		ret.push_back({name = "pitch_index", type=TYPE_INT})
	
	return ret
