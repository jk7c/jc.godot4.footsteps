class_name FPCamera extends Node3D

@export var mouse_sensitive: float = 0.005:
	get: return mouse_sensitive
	set(value):
		mouse_sensitive = value

@export var x_clamp:= Vector2(-65.0, 80.0):
	get: return x_clamp
	set(value):
		x_clamp = value

@export var target: Node3D = null:
	get: return target
	set(value):
		target = value

@export var camera: Camera3D = null:
	get: return camera
	set(value):
		camera = value

var _player: FPCharacter = null
var _prev_tr:= Transform3D()
var _current_tr:= Transform3D()
var _is_fixed_update: bool = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		_player = get_parent() as FPCharacter

func _ready() -> void:
	top_level = true
	target = target
	
	if camera == null:
		push_warning("Camera not found")
	else:
		global_position = target.position
	
	_prev_tr = target.global_transform
	_current_tr = target.global_transform
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouseMotion:= event as InputEventMouseMotion
		
		rotation.x -= mouseMotion.relative.y * mouse_sensitive
		rotation.x = clamp(rotation.x, deg_to_rad(x_clamp.x), deg_to_rad(x_clamp.y))
		
		rotation.y -= mouseMotion.relative.x * mouse_sensitive
		rotation.y = wrapf(rotation.y, 0.0, deg_to_rad(360.0))

func _process(delta: float) -> void:
	if _player == null:
		return
	
	_player.yaw_rotation = self.rotation.y
	if target == null:
		return
	
	if _is_fixed_update:
		_prev_tr = _current_tr
		_current_tr = target.global_transform
		_is_fixed_update = false
	
	var fraction = clamp(Engine.get_physics_interpolation_fraction(), 0.0, 1.0)
	global_position = _prev_tr.origin.lerp(_current_tr.origin, fraction)

func _physics_process(delta):
	_is_fixed_update = true
