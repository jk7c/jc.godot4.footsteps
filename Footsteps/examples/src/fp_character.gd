class_name FPCharacter extends CharacterBody3D

# Speed.
@export var walk_speed: float = 5.0:
	get: return walk_speed
	set(value):
		walk_speed = value

@export var sprint_speed: float = 7.0:
	get: return sprint_speed
	set(value):
		sprint_speed = value

# Jump.
@export var jump_force: float = 5.0:
	get: return jump_force
	set(value):
		jump_force = value

# Rotation.
@export var rotation_speed: float:
	get: return rotation_speed
	set(value):
		rotation_speed = value

var yaw_rotation: float = 0.0:
	get: return yaw_rotation
	set(value):
		yaw_rotation = value

# Gravity.
@export var gravity_modifier: float = 2.0:
	get: return gravity_modifier
	set(value):
		gravity_modifier = value

# Private global variables.
var _internal_jump_force: float = 0.0
var _speed_mul: float = 1.0

# Direction.
var _input_dir:= Vector3.ZERO
var _move_dir:= Vector3.ZERO

var _old_strafe_move_dir: Vector3
var _strafe_move_dir: Vector3

# States.
var _is_sprinting: bool = false
var get_is_sprinting: bool:
	get: return _is_sprinting

var _is_jumping: bool = false
var get_is_jumping: bool:
	get: return _is_jumping

var _get_gravity_force:
	get: return 9.8 * gravity_modifier

func _ready() -> void:
	max_slides = 6;

func _unhandled_input(event: InputEvent) -> void:
	_input_dir = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0.0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_front")
	)
	_is_sprinting = Input.get_action_strength("sprint") > 0.0

func _compute_speed_mul() -> void:
	_speed_mul = sprint_speed if _is_sprinting else walk_speed
	_internal_jump_force = (jump_force + velocity.length()) * 0.7

func _jump() -> void:
	velocity.y = _internal_jump_force

func _add_gravity_force(force: float, delta: float) -> void:
	velocity.y -= force * delta

func _yaw(delta: float) -> void:
	var smd := Vector3.FORWARD.rotated(Vector3.UP, yaw_rotation).normalized();
	_old_strafe_move_dir = _strafe_move_dir
	
	var look:= Vector2(smd.z, smd.x)
	
	_strafe_move_dir = lerp(_strafe_move_dir, smd, delta * 45.0)
	transform.basis = transform.basis.from_euler(Vector3.UP * look.angle())

func _physics_process(delta: float) -> void:
	# Add gravity
	if !is_on_floor():
		_add_gravity_force(_get_gravity_force, delta)
	
	_move_dir.x = _input_dir.x
	_move_dir.z = _input_dir.z
	_move_dir = _move_dir.rotated(Vector3.UP, yaw_rotation).normalized()
	
	_compute_speed_mul()
	if is_on_floor():
		velocity.x = _move_dir.x * _speed_mul
		velocity.z = _move_dir.z * _speed_mul
	
	_is_jumping = is_on_floor() && Input.is_action_just_pressed("jump")
	
	if is_on_floor():
		if _is_jumping:
			_jump()
	
	_yaw(delta)
	move_and_slide()
