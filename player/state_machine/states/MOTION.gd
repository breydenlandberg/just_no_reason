class_name Motion extends State


# signals
signal velocity_updated(vel: Vector3)
@warning_ignore('unused_signal')
signal _animation_state_changed(state: String)
@warning_ignore('unused_signal')
signal _input_direction_changed(_input_dir: Vector2)
@warning_ignore('unused_signal')
signal sprint_started
@warning_ignore('unused_signal')
signal sprint_ended

# const
const PLAYER_MOVEMENT_STATS = preload('res://player/player_movement_stats.tres')

# var
var base_speed: float
var sprint_speed: float
var aim_speed: float
var jump_gravity: float
var fall_gravity: float
var jump_velocity: float

static var input_dir := Vector2.ZERO
static var direction := Vector3.ZERO
static var velocity := Vector3.ZERO
static var sprint_remaining := 0.0


### fn

## virtual
#
func _ready():
	velocity_updated.connect(owner.set_velocity_from_motion)

	base_speed = PLAYER_MOVEMENT_STATS.get_velocity(
		PLAYER_MOVEMENT_STATS.jump_distance,
		PLAYER_MOVEMENT_STATS.time_to_jump_apex + PLAYER_MOVEMENT_STATS.time_to_land
	)
	sprint_speed = PLAYER_MOVEMENT_STATS.get_velocity(
		PLAYER_MOVEMENT_STATS.sprint_jump_distance,
		PLAYER_MOVEMENT_STATS.time_to_jump_apex + PLAYER_MOVEMENT_STATS.time_to_land
	)
	aim_speed = PLAYER_MOVEMENT_STATS.get_velocity(
		PLAYER_MOVEMENT_STATS.aim_jump_distance,
		PLAYER_MOVEMENT_STATS.time_to_jump_apex + PLAYER_MOVEMENT_STATS.time_to_land
	)
	jump_gravity = PLAYER_MOVEMENT_STATS.get_jump_gravity()
	fall_gravity = PLAYER_MOVEMENT_STATS.get_fall_gravity()
	jump_velocity = PLAYER_MOVEMENT_STATS.get_jump_velocity(jump_gravity)

	sprint_remaining = PLAYER_MOVEMENT_STATS.sprint_duration

## helper
#
func is_on_floor() -> bool:
	return owner.is_on_floor()

func set_direction():
	input_dir = Input.get_vector(InputManager.input_left, InputManager.input_right, InputManager.input_forward, InputManager.input_back)
	direction = (entity.camera.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

func calculate_velocity(_speed: float, _direction: Vector3, _acceleration: float, _delta: float):
	velocity.x = move_toward(velocity.x, _direction.x * _speed, _acceleration * _delta)
	velocity.z = move_toward(velocity.z, _direction.z * _speed, _acceleration * _delta)
	velocity_updated.emit(velocity)

func calculate_gravity(_delta: float):
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y -= jump_gravity * _delta
		else:
			velocity.y -= fall_gravity * _delta

func rotate_model():
	if input_dir != Vector2(0, 0):
		%PlayerModelAnimated.rotation_degrees.y = entity.camera.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90

func replenish_sprint(delta: float):
	sprint_remaining = min(sprint_remaining + delta, PLAYER_MOVEMENT_STATS.sprint_duration)
