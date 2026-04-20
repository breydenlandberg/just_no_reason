extends Node3D


# var
var camera_rotation := Vector2.ZERO
var max_y_rotation := 1.0
var mouse_captured := true
var mouse_sensitivity := 0.001

var camera_tween: Tween

# @export
@export var camera_alignment_speed := 0.1 # Why does it get slower the higher the number?

# @onready
@onready var edge_spring_arm := $EdgeSpringArm
@onready var default_edge_sprint_arm_length: float = edge_spring_arm.spring_length


### fn

## virtual
#
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()

	if mouse_captured and event is InputEventMouseMotion:
		var mouse_event: Vector2 = event.screen_relative * mouse_sensitivity
		camera_look(mouse_event)

	if event.is_action_pressed('swap_camera_alignment'):
		swap_camera_alignment()


## helper
#
func camera_look(mouse_movement: Vector2):
	camera_rotation += mouse_movement

	transform.basis = Basis()

	rotate_object_local(Vector3(0,1,0), -camera_rotation.x)
	rotate_object_local(Vector3(1,0,0), -camera_rotation.y)

	camera_rotation.y = clampf(camera_rotation.y, -max_y_rotation, max_y_rotation)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func set_rear_spring_arm_position(pos: float, speed: float):
	if camera_tween:
		camera_tween.kill()

	camera_tween = get_tree().create_tween()
	camera_tween.tween_property(edge_spring_arm, 'spring_length', pos, speed)

func swap_camera_alignment():
	default_edge_sprint_arm_length = -default_edge_sprint_arm_length

	set_rear_spring_arm_position(default_edge_sprint_arm_length, camera_alignment_speed)
