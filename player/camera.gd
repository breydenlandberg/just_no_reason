extends Node3D


# enums
enum CameraAlignment {LEFT = -1, CENTRE = 0, RIGHT = 1}

# vars
var camera_rotation := Vector2.ZERO
var camera_tween: Tween
var max_y_rotation := 1.0
var mouse_captured := false
var mouse_sensitivity := 0.001
var current_camera_alignment: int = CameraAlignment.RIGHT

@export var player: CharacterBody3D
@export var camera_alignment_duration := 0.1

@export var aim_fov := 65.0
@export var aim_edge_spring_length := 1.0
@export var aim_rear_spring_length := 2.0
@export var aim_duration := 0.075
@export var sprint_fov := 85.0
@export var sprint_tween_duration := 0.1

@onready var camera: Camera3D = $EdgeSpringArm/RearSpringArm/Camera3D; @onready var default_fov: float = camera.fov
@onready var edge_spring_arm: SpringArm3D = $EdgeSpringArm;	@onready var default_edge_spring_arm_length: float = edge_spring_arm.spring_length
@onready var rear_spring_arm: SpringArm3D = $EdgeSpringArm/RearSpringArm; @onready var default_rear_spring_arm_length: float = rear_spring_arm.spring_length


### fn

## virtual
#
func _ready():
	PauseManager.pause_requested.connect(handle_mouse_pause)

func _unhandled_input(event: InputEvent):
	if mouse_captured and event is InputEventMouseMotion:
		var mouse_event: Vector2 = event.screen_relative * mouse_sensitivity
		camera_look(mouse_event)

	if Input.is_action_just_pressed(InputManager.swap_camera_alignment):
		swap_camera_alignment()


## mouse / look
#
func camera_look(mouse_movement: Vector2) -> void:
	camera_rotation += mouse_movement

	transform.basis = Basis()

	rotate_object_local(Vector3(0,1,0), -camera_rotation.x)
	rotate_object_local(Vector3(1,0,0), -camera_rotation.y)

	camera_rotation.y = clampf(camera_rotation.y, -max_y_rotation, max_y_rotation)

# capture / release mouse

func handle_mouse_pause() -> void:
	if PauseManager.currently_paused:
		release_mouse()
	else:
		capture_mouse()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## stance & alignment
#
# aim / shoulder alignment
func enter_aim() -> void:
	tween_camera_properties({
		camera: ['fov', aim_fov],
		edge_spring_arm: ["spring_length", aim_edge_spring_length * current_camera_alignment],
		rear_spring_arm: ["spring_length", aim_rear_spring_length]
	}, aim_duration)#, Tween.TRANS_EXPO, Tween.EASE_OUT)

func exit_aim() -> void:
	tween_camera_properties({
		camera: ['fov', default_fov],
		edge_spring_arm: ["spring_length", default_edge_spring_arm_length * current_camera_alignment],
		rear_spring_arm: ["spring_length", default_rear_spring_arm_length]
	}, aim_duration)#, Tween.TRANS_EXPO, Tween.EASE_OUT)

func swap_camera_alignment() -> void:
	match current_camera_alignment:
		CameraAlignment.LEFT:
			current_camera_alignment = CameraAlignment.RIGHT
		CameraAlignment.CENTRE:
			return
		CameraAlignment.RIGHT:
			current_camera_alignment = CameraAlignment.LEFT

	var new_pos: float = default_edge_spring_arm_length * current_camera_alignment

	tween_camera_property(edge_spring_arm, 'spring_length', new_pos, camera_alignment_duration)

# sprint
func enter_sprint() -> void:
	tween_camera_properties({
		camera: ['fov', sprint_fov],
		edge_spring_arm: ["spring_length", default_edge_spring_arm_length * current_camera_alignment],
		rear_spring_arm: ["spring_length", default_rear_spring_arm_length]
	}, sprint_tween_duration)#, Tween.TRANS_EXPO, Tween.EASE_OUT)

func exit_sprint() -> void:
	tween_camera_properties({
		camera: ['fov', default_fov],
		edge_spring_arm: ["spring_length", default_edge_spring_arm_length * current_camera_alignment],
		rear_spring_arm: ["spring_length", default_rear_spring_arm_length]
	}, sprint_tween_duration)#, Tween.TRANS_EXPO, Tween.EASE_OUT)


## tweens
#
# tween
func kill_camera_tween() -> void:
	if camera_tween:
		camera_tween.kill()

func tween_camera_property(target: Object, property: String, value: Variant, duration: float) -> void:
	kill_camera_tween()

	camera_tween = get_tree().create_tween().set_parallel() # set_parellel() ?
	camera_tween.tween_property(target, property, value, duration)

# TRANS_LINEAR and EASE_IN_OUT are Camera3D defaults
func tween_camera_properties(properties: Dictionary, duration: float, trans := Tween.TRANS_LINEAR, ease_param := Tween.EASE_IN_OUT) -> void:
	kill_camera_tween()

	camera_tween = get_tree().create_tween().set_parallel() # set_parallel() ?

	camera_tween.set_trans(trans)
	camera_tween.set_ease(ease_param)

	for target in properties:
		var pair = properties[target]
		camera_tween.tween_property(target, pair[0], pair[1], duration)


## signals
#
func _on_aim_changed(is_aiming: bool) -> void:
	if is_aiming:
		enter_aim()
	else:
		exit_aim()

func _on_sprint_changed(is_sprinting: bool) -> void:
	if is_sprinting:
		enter_sprint()
	else:
		exit_sprint()
