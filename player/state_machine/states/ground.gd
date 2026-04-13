extends State

###

# var
var player: CharacterBody3D

# @export
@export var jump_velocity := 10.0


### fn

## virtual
#
func _enter():
	player = entity

func _state_input(_event: InputEvent):
	if player.is_on_floor():
		if _event.is_action_pressed('jump') and player.can_jump:
			jump()
		# Handle crouch
		if player.can_attack and not player.is_attacking:
			if _event.is_action_pressed('attack_basic'):
				attack_basic()

func _state_physics_process(_delta: float):
	if player.is_on_floor():
		if can_play_default_animation():
			if player.velocity.length() > 0:
				animation.play('Walk')
			else:
				animation.play('Idle')

		handle_sprint()
	else:
		_transition.emit(self, 'air')


## helper
#
func attack_basic():
	player.is_attacking = true
	player.speed = player.base_speed * 0.25

	animation.play('Punch_Jab')

func can_play_default_animation() -> bool:
	match animation.current_animation:
		'Punch_Jab':
			return false
		_:
			if player.is_attacking:
				return false
			else:
				return true

func handle_sprint():
	if player.can_sprint and Input.is_action_pressed(player.input_sprint):
		player.speed = player.sprint_speed
	else:
		player.speed = player.base_speed

func jump():
	player.velocity.y = jump_velocity
	
	#if animation.current_animation != 'attack_basic':
	animation.play('Jump')
