extends State


# var
@export var input_left := 'left'
@export var input_right := 'right'
@export var input_forward := 'up'
@export var input_back := 'down'
var player: CharacterBody3D

# @export
@export var freefly_speed := 32.0

# @onready
@onready var camera: Node3D
@onready var player_model: Node3D


### fn

## virtual
#
func _enter():
	player = entity
	camera = player.camera
	player_model = player.player_model

	player.set_collision_mask_value(1, false)
	player.velocity = Vector3.ZERO
	player.is_freeflying = true

func _exit():
	player.set_collision_mask_value(1, true)
	player.is_freeflying = false

func _state_physics_process(_delta: float):
	var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
	var motion := (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	motion *= freefly_speed * _delta

	if input_dir != Vector2(0, 0):
		player_model.rotation_degrees.y = camera.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90

	player.move_and_collide(motion)
