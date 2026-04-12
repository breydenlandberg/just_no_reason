extends CharacterBody3D


# var
### donot make these all caps lol
var is_attacking := false
var CROUCHING := false
var FREEFLYING := false
var SPEED := 0.0

# @export
@export_group('Toggles')
@export var can_move := true
@export var has_gravity := true
@export var can_jump := true
@export var can_sprint := true
@export var can_freefly := true
@export var can_crouch := true
@export var can_interact := true
@export var can_attack := true

@export_group('Speeds')
@export var base_speed := 8.0
@export var sprint_speed := 10.0
@export var freefly_speed := 25.0

@export_group('Input Actions')
@export var input_left := 'left'
@export var input_right := 'right'
@export var input_forward := 'up'
@export var input_back := 'down'
@export var input_jump := 'jump'
@export var input_sprint := 'sprint'
@export var input_freefly := 'freefly'
@export var input_crouch := 'crouch'
@export var input_interact := 'interact'
@export var input_attack_basic := 'attack_basic'

# @onready
@onready var ui_manager := %UIManager

@onready var camera: Node3D = $Camera
@onready var collider := $CollisionShape3D
@onready var player_model := $PlayerModel


### fn

## virtual
#
func _ready():
	check_input_mappings()
	InteractManager.set_player(self)
	# Does below need to be a signal?
	SignalBus._message.connect(message)

func _unhandled_input(event: InputEvent):
	# Handle freefly mode
	if can_freefly and event.is_action_pressed(input_freefly):
		if not FREEFLYING:
			enable_freefly()
		else:
			disable_freefly()

	# Handle crouch (toggle)
	if can_crouch and event.is_action_pressed(input_crouch):
		if not CROUCHING:
			enable_crouch()
		else:
			disable_crouch()

	# Handle interactions
	if can_interact and event.is_action_pressed(input_interact):
		InteractManager.execute_current_interaction()

func _physics_process(delta: float):
	# If FREEFLYING, handle freefly and nothing else
	if can_freefly and FREEFLYING:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta

		if input_dir != Vector2(0, 0):
			player_model.rotation_degrees.y = camera.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90

		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
		SPEED = sprint_speed
	else:
		SPEED = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var direction := (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if input_dir != Vector2(0, 0):
			player_model.rotation_degrees.y = camera.rotation_degrees.y - rad_to_deg(input_dir.angle()) + 90

		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()


### helper
#
func enable_freefly():
	set_collision_mask_value(1, false)
	FREEFLYING = true
	velocity = Vector3.ZERO

func disable_freefly():
	set_collision_mask_value(1, true)
	FREEFLYING = false

func enable_crouch():
	#mesh.mesh.height = 1.2
	collider.shape.height = 1.2
	#mesh.position.y = 0.6
	collider.position.y = 0.6
	CROUCHING = true

func disable_crouch():
	#mesh.mesh.height = 1.8
	collider.shape.height = 1.8
	#mesh.position.y = 0.9
	collider.position.y = 0.9
	CROUCHING = false

func handle_input():
	if Input.is_action_just_pressed('interact'):
		InteractManager.execute_current_interaction()

## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error('Movement disabled. No InputAction found for input_left: ' + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error('Movement disabled. No InputAction found for input_right: ' + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error('Movement disabled. No InputAction found for input_forward: ' + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error('Movement disabled. No InputAction found for input_back: ' + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error('Jumping disabled. No InputAction found for input_jump: ' + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error('Sprinting disabled. No InputAction found for input_sprint: ' + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error('Freefly disabled. No InputAction found for input_freefly: ' + input_freefly)
		can_freefly = false
	if can_crouch and not InputMap.has_action(input_crouch):
		push_error('Crouch disabled. No InputAction found for input_crouch: ' + input_crouch)
		can_freefly = false
	if can_interact and not InputMap.has_action(input_interact):
		push_error('Crouch disabled. No InputAction found for input_interact: ' + input_interact)
		can_freefly = false
	if can_attack and not InputMap.has_action(input_attack_basic):
		push_error('Attack basic disabled. No InputAction found for attack_basic: ' + input_crouch)
		can_freefly = false

## SignalBus
#
func message(text: String):
	var messages = ui_manager.get_node('MasterContainer/Message/PanelContainer/MarginContainer/ScrollContainer/Messages')
	
	if messages.text.length() > 0:
		messages.text += ('\n' + text)  
	else: 
		messages.text += text


## signals
#
# interact
func _on_interact_area_entered(interaction: Interaction):
	InteractManager.push_front(interaction)
	InteractManager.update_interact_label()

func _on_interact_area_exited(interaction: Interaction):
	InteractManager.erase(interaction)
	InteractManager.update_interact_label()
