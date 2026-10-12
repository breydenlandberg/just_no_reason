class_name Player extends CharacterBody3D


# signals
signal aim_changed(is_aiming: bool)
signal sprint_changed(is_sprinting: bool)

# vars
var is_freeflying := false
var is_aiming := false
var is_sprinting := false
var is_crouching := false
var is_attacking := false

@export_group('Toggles')
@export var has_gravity := true
@export var can_freefly := true
@export var can_move := true
@export var can_jump := true
@export var can_aim := true
@export var can_sprint := true
@export var can_crouch := true
@export var can_interact := true
@export var can_use_combat := true
@export_group('Nodes')
@export var player_model_animated: PlayerModelAnimated
@export var camera: Node3D # un-unique name Camera pls
@export var weapon_manager: WeaponManager


### fn

## virtual
#
func _ready():
	_check_input_mappings()
	InteractManager.set_player(self)
	# Does below need to be a signal?
	#SignalBus._message.connect(message)

	if player_model_animated:
		aim_changed.connect(player_model_animated._on_aim_changed)

	if camera:
		aim_changed.connect(camera._on_aim_changed)
		sprint_changed.connect(camera._on_sprint_changed)

	if weapon_manager:
		weapon_manager.weapon_manager_started.connect(SignalBus.weapon_manager_started.emit)
		weapon_manager.weapon_manager_stopped.connect(SignalBus.weapon_manager_stopped.emit)
		weapon_manager.ammo_updated.connect(SignalBus.ammo_updated.emit)

func _unhandled_input(event: InputEvent):
	# Handle interactions
	if can_interact and event.is_action_pressed(InputManager.interact):
		InteractManager.execute_current_interaction()

func _physics_process(_delta: float):
	if not is_freeflying:
		move_and_slide()


## public
#
func activate(spawn_transform: Transform3D) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	show()

	velocity = Vector3.ZERO
	global_transform = spawn_transform

	if camera:
		camera.capture_mouse()

func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

	if camera:
		camera.release_mouse()

func set_velocity_from_motion(vel: Vector3) -> void:
	velocity = vel

func set_aiming(value: bool) -> void:
	if is_aiming == value:
		return

	is_aiming = value
	aim_changed.emit(is_aiming)

func set_sprinting(value: bool) -> void:
	if is_sprinting == value:
		return

	is_sprinting = value
	sprint_changed.emit(is_sprinting)


## internal
#
func _check_input_mappings() -> void:
	var check_action = func(_action: String, _action_type: String, _flag: String):
		if not InputMap.has_action(_action):
			push_error('{_action_type} disabled. No InputAction found: {_action}')
			set(_flag, false)

	var action_type := ''
	var flag := ''

	if can_freefly: check_action.call(InputManager.freefly, 'Freefly', 'can_freefly')
	if can_move:
		action_type = 'Movement'
		flag = 'can_move'

		check_action.call(InputManager.forward, 'Movement', 'can_move')
		check_action.call(InputManager.back, 'Movement', 'can_move')
		check_action.call(InputManager.left, 'Movement', 'can_move')
		check_action.call(InputManager.right, 'Movement', 'can_move')
	if can_jump: check_action.call(InputManager.jump, 'Jumping', 'can_jump')
	if can_aim: check_action.call(InputManager.aim, 'Aiming', 'can_aim')
	if can_sprint: check_action.call(InputManager.sprint, 'Sprinting', 'can_sprint')
	if can_crouch: check_action.call(InputManager.crouch, 'Crouch', 'can_crouch')
	if can_interact: check_action.call(InputManager.interact, 'Interaction', 'can_interact')
	if can_use_combat:
		action_type = 'Use combat system'
		flag = 'can_use_combat'

		check_action.call(InputManager.attack_basic, action_type, flag)
		check_action.call(InputManager.shoot, action_type, flag)
		check_action.call(InputManager.reload_input, action_type, flag)
		check_action.call(InputManager.change_weapon, action_type, flag)
		check_action.call(InputManager.drop_weapon, action_type, flag)


## SignalBus
#
#func message(text: String):
	#var messages = ui_manager.get_node('MasterContainer/PanelContainer/MarginContainer/ScrollContainer/Messages')
#
	#if messages.text.length() > 0:
		#messages.text += ('\n' + text)  
	#else: 
		#messages.text += text


## signals
# interact
func _on_interact_area_entered(interaction: Interaction) -> void:
	InteractManager.push_front(interaction)
	#InteractManager.update_interact_label()

func _on_interact_area_exited(interaction: Interaction) -> void:
	InteractManager.erase(interaction)
	#InteractManager.update_interact_label()
