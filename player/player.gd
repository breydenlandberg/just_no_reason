extends CharacterBody3D


# var
var is_freeflying := false
var is_aiming := false
var is_sprinting := false
var is_crouching := false
var is_attacking := false

# @export
@export_group('Toggles')
@export var can_freefly := true
@export var can_move := true
@export var can_jump := true
@export var can_aim := true
@export var can_sprint := true
@export var can_crouch := true
@export var can_interact := true
@export var can_attack := true
@export var has_gravity := true

@export_group('Speeds')
@export var base_speed := 8.0

# @onready
@onready var ui_manager := %UIManager
@onready var camera: Node3D = $Camera


### fn

## virtual
#
func _physics_process(_delta: float):
	if not is_freeflying:
		move_and_slide()

func _ready():
	check_input_mappings()
	InteractManager.set_player(self)
	# Does below need to be a signal?
	SignalBus._message.connect(message)

func _unhandled_input(event: InputEvent):
	# Handle interactions
	if can_interact and event.is_action_pressed(InputManager.interact):
		InteractManager.execute_current_interaction()


## helper
#
func check_input_mappings():
	if can_freefly and not InputMap.has_action(InputManager.freefly):
		push_error('Freefly disabled. No InputAction found for InputManager.freefly: ' + InputManager.freefly)
		can_freefly = false
	if can_move and not InputMap.has_action(InputManager.forward):
		push_error('Movement disabled. No InputAction found for InputManager.forward: ' + InputManager.forward)
		can_move = false
	if can_move and not InputMap.has_action(InputManager.back):
		push_error('Movement disabled. No InputAction found for InputManager.back: ' + InputManager.back)
		can_move = false
	if can_move and not InputMap.has_action(InputManager.left):
		push_error('Movement disabled. No InputAction found for InputManager.left: ' + InputManager.left)
		can_move = false
	if can_move and not InputMap.has_action(InputManager.right):
		push_error('Movement disabled. No InputAction found for InputManager.right: ' + InputManager.right)
		can_move = false
	if can_jump and not InputMap.has_action(InputManager.jump):
		push_error('Jumping disabled. No InputAction found for InputManager.jump: ' + InputManager.jump)
		can_jump = false
	if can_aim and not InputMap.has_action(InputManager.aim):
		push_error('Jumping disabled. No InputAction found for InputManager.aim: ' + InputManager.aim)
		can_aim = false
	if can_sprint and not InputMap.has_action(InputManager.sprint):
		push_error('Sprinting disabled. No InputAction found for InputManager.sprint: ' + InputManager.sprint)
		can_sprint = false
	if can_crouch and not InputMap.has_action(InputManager.crouch):
		push_error('Crouch disabled. No InputAction found for InputManager.crouch: ' + InputManager.crouch)
		can_crouch = false
	if can_interact and not InputMap.has_action(InputManager.interact):
		push_error('Crouch disabled. No InputAction found for InputManager.interact: ' + InputManager.interact)
		can_interact = false
	if can_attack and not InputMap.has_action(InputManager.attack_basic):
		push_error('Basic attack disabled. No InputAction found for InputManager.attack_basic: ' + InputManager.attack_basic)
		can_attack = false

func set_velocity_from_motion(vel: Vector3):
	velocity = vel

## SignalBus
#
func message(text: String):
	var messages = ui_manager.get_node('MasterContainer/PanelContainer/MarginContainer/ScrollContainer/Messages')

	if messages.text.length() > 0:
		messages.text += ('\n' + text)  
	else: 
		messages.text += text


## signals
# interact
func _on_interact_area_entered(interaction: Interaction):
	InteractManager.push_front(interaction)
	InteractManager.update_interact_label()

func _on_interact_area_exited(interaction: Interaction):
	InteractManager.erase(interaction)
	InteractManager.update_interact_label()
