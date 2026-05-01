extends State


# var
var attack_basic_current_phase := 0
var attack_basic_phase_limit := 2
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
		# Handle crouch
	else:
		_transition.emit(self, 'air')


## helper
#
func attack_basic():
	player.is_attacking = true
	player.speed = player.base_speed * 0.25

	match attack_basic_current_phase:
		0:
			animation.play('Punch_Jab')
		1:
			animation.play('Punch_Cross')
		2:
			animation.play('Spell_Simple_Shoot')

	if attack_basic_current_phase < attack_basic_phase_limit:
		attack_basic_current_phase += 1
	else:
		attack_basic_current_phase = 0

func can_play_default_animation() -> bool:
	match animation.current_animation:
		'Punch_Jab', 'Punch_Cross', 'Spell_Simple_Shoot':
			return false
		_:
			if player.is_attacking: # or???
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

	match animation.current_animation:
		'Punch_Jab', 'Punch_Cross', 'Spell_Simple_Shoot':
			animation.play('Jump')
