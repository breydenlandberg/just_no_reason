extends Node3D


# var
var camera_rotation := Vector2.ZERO
var camera_tween: Tween
var max_y_rotation := 1.0
var mouse_captured := true
var mouse_sensitivity := 0.001

# @export
@export var aim_fov := 55
@export var aim_edge_spring_length := 1.0
@export var aim_rear_spring_length := 1.0
@export var aim_speed := 0.5
@export var camera_alignment_speed := 0.1 # Why does it get slower the higher the number?
@export var sprint_fov := 90.0
@export var sprint_tween_speed := 0.5

# @onready
@onready var camera: Camera3D = $EdgeSpringArm/RearSpringArm/Camera3D; @onready var default_fov: float = camera.fov
@onready var edge_spring_arm: SpringArm3D = $EdgeSpringArm;	@onready var default_edge_spring_arm_length: float = edge_spring_arm.spring_length
@onready var rear_spring_arm: SpringArm3D = $EdgeSpringArm/RearSpringArm; @onready var default_rear_spring_arm_length: float = rear_spring_arm.spring_length


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

	if Input.is_action_just_pressed('swap_camera_alignment'):
		swap_camera_alignment()

	if Input.is_action_pressed('aim'):
		enter_aim()

	if Input.is_action_just_released('aim'):
		exit_aim()

	if Input.is_action_pressed('sprint'):
		enter_sprint()

	if Input.is_action_just_released('sprint'):
		exit_sprint()

## helper
#
func camera_look(mouse_movement: Vector2):
	camera_rotation += mouse_movement

	transform.basis = Basis()

	rotate_object_local(Vector3(0,1,0), -camera_rotation.x)
	rotate_object_local(Vector3(1,0,0), -camera_rotation.y)

	camera_rotation.y = clampf(camera_rotation.y, -max_y_rotation, max_y_rotation)

# capture / release mouse
func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

# aim / shoulder alignment
func enter_aim():
	tween_camera_properties({
		camera: ['fov', aim_fov],
		edge_spring_arm: ["spring_length", aim_edge_spring_length * sign(edge_spring_arm.spring_length)],
		rear_spring_arm: ["spring_length", aim_rear_spring_length]
	}, aim_speed, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)

func exit_aim():
	tween_camera_properties({
		camera: ['fov', aim_fov],
		edge_spring_arm: ["spring_length", default_edge_spring_arm_length * sign(edge_spring_arm.spring_length)],
		rear_spring_arm: ["spring_length", default_rear_spring_arm_length]
	}, aim_speed, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)

func swap_camera_alignment():
	default_edge_spring_arm_length = -default_edge_spring_arm_length

	tween_camera_property(edge_spring_arm, 'spring_length', default_edge_spring_arm_length, camera_alignment_speed)

# sprint
func enter_sprint():
	tween_camera_properties({
		camera: ['fov', sprint_fov],
		edge_spring_arm: ["spring_length", default_edge_spring_arm_length * sign(edge_spring_arm.spring_length)],
		rear_spring_arm: ["spring_length", default_rear_spring_arm_length]
	}, sprint_tween_speed, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)

func exit_sprint():
	tween_camera_properties({
		camera: ['fov', default_fov],
		edge_spring_arm: ["spring_length", default_edge_spring_arm_length * sign(edge_spring_arm.spring_length)],
		rear_spring_arm: ["spring_length", default_rear_spring_arm_length]
	}, sprint_tween_speed, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)

# tween
func kill_camera_tween():
	if camera_tween:
		camera_tween.kill()

func tween_camera_property(target: Object, property: String, value: Variant, duration: float):
	kill_camera_tween()

	camera_tween = get_tree().create_tween().set_parallel() # ?
	camera_tween.tween_property(target, property, value, duration)

func tween_camera_properties(properties: Dictionary, duration: float, trans: Tween.TransitionType, ease: Tween.EaseType):
	kill_camera_tween()

	camera_tween = get_tree().create_tween().set_parallel() # ?
	#if no trans or ease?
	camera_tween.set_trans(trans)
	camera_tween.set_ease(ease)

	for target in properties:
		var pair = properties[target]
		camera_tween.tween_property(target, pair[0], pair[1], duration)
