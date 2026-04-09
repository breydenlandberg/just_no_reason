extends State


# var
var player: CharacterBody3D
var has_double_jumped := false

# @export
@export var double_jump_velocity := 5.0


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
	if player.is_on_floor():
		_transition.emit(self, 'ground')


## helper
#
func double_jump():
	player.velocity.y = double_jump_velocity

	has_double_jumped = true
