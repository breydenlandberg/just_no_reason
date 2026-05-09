extends State


# var
var attack_basic_current_phase := 0
var attack_basic_phase_limit := 2
var player: CharacterBody3D

# @export
@export var jump_velocity := 5.0


### fn

## virtual
#
func _enter():
	player = entity

func _state_input(_event: InputEvent):
	if player.is_on_floor():
		if _event.is_action_pressed('jump') and player.can_jump:
			pass
		if player.can_attack and not player.is_attacking:
			if _event.is_action_pressed('attack_basic'):
				attack_basic()

func _state_physics_process(_delta: float):
	if player.is_on_floor():
		if can_play_default_animation():
			if player.velocity.length() > 0:
				pass
			else:
				pass

		handle_sprint()
		handle_crouch()
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
	if animation.current_animation in ['Jump_Land']:
		return false

	if player.is_sprinting or player.is_crouching or player.is_attacking:
		return false

	return true

func handle_crouch():
	if player.can_crouch and Input.is_action_pressed(player.input_crouch):
		animation.play('Crouch_Idle')

		player.is_crouching = true
	else:
		player.is_crouching = false

func handle_sprint():
	if player.can_sprint and Input.is_action_pressed(player.input_sprint):# and player.velocity.length() > 0
		# and handle the crouch case too
		player.speed = player.sprint_speed

		if animation.current_animation not in ['Jump_Land'] and not player.is_attacking:
			animation.play('Jog_Fwd')

		player.is_sprinting = true
	else:
		player.speed = player.base_speed
		player.is_sprinting = false
