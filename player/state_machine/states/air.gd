extends State


# var
var player: CharacterBody3D
var has_double_jumped := false

# @export
@export var double_jump_velocity := 15.0


### fn

## virtual
#
func _enter():
	player = entity

func _exit():
	has_double_jumped = false

func _state_input(_event: InputEvent):
	if _event.is_action_pressed('jump') and not has_double_jumped:
		double_jump()

func _state_physics_process(_delta: float):
	if not player.is_attacking and not animation.current_animation == 'Jump_Start':
		pass

	if player.is_on_floor():
		_transition.emit(self, 'ground')


## helper
#
func double_jump():
	player.velocity.y = double_jump_velocity

	if not player.is_attacking:
		animation.stop()
		animation.play('Jump_Start')

	has_double_jumped = true
