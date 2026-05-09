class_name Motion extends State
# Why is this inheriting State? I want my States to be States not "Motions" ... use composition if possible


# signals
signal velocity_updated(vel: Vector3)

# const
const base_speed := 8.0
const jump_velocity := 5.0
const gravity := -9.8
const acceleration := 1000.0

# var
static var input_dir := Vector2.ZERO
static var direction := Vector3.ZERO
static var velocity := Vector3.ZERO


### fn

## virtual
#
func _ready():
	velocity_updated.connect(owner.set_velocity_from_motion)

## helper
#
func set_direction():
	input_dir = Input.get_vector(InputManager.input_left, InputManager.input_right, InputManager.input_forward, InputManager.input_back)
	direction = (owner.camera.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

func calculate_velocity(_speed: float, _direction: Vector3, _delta: float):
	velocity.x = move_toward(velocity.x, _direction.x * _speed, acceleration * _delta)
	velocity.z = move_toward(velocity.z, _direction.z * _speed, acceleration * _delta)
	velocity_updated.emit(velocity)

func calculate_gravity(_delta: float):
	if not owner.is_on_floor():
		velocity.y += gravity * _delta
