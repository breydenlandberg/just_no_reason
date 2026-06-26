extends PlayerMotionState


# var
var player: CharacterBody3D

# @export
@export var freefly_speed := 32.0

# @onready
@onready var camera: Node3D
#@onready var player_model: Node3D


### fn

## virtual
#
func _enter():
	owner.is_freeflying = true
	camera = owner.camera
	owner.set_collision_mask_value(1, false)

	super._enter()

func _exit():
	owner.set_collision_mask_value(1, true)
	owner.is_freeflying = false

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.freefly):
		_transition.emit(self, 'idle')

func _state_physics_process(_delta: float):
	var _input_dir := Input.get_vector(InputManager.left, InputManager.right, InputManager.forward, InputManager.back)
	var motion := (camera.global_basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	motion *= freefly_speed * _delta

	_rotate_model.emit(_input_dir)
	replenish_sprint(_delta)

	if motion == Vector3.ZERO:
		_animation_state_changed.emit('freefly_idle')
	else:
		_animation_state_changed.emit('freefly_move')

	owner.move_and_collide(motion)
