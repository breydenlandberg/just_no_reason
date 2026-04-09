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
		if _event.is_action_pressed('jump'):
			jump()

func _state_physics_process(_delta: float):
	if player.is_on_floor():
		#if playerCanPlayDefaultAnim():
		if player.velocity.length() > 0:
			animation.play('Walk')
		else:
			animation.play('Idle')
	else:
		_transition.emit(self, 'air')


## helper
#
func jump():
	player.velocity.y = jump_velocity
	
	#if animation.current_animation != 'attack_basic':
	animation.play('Jump')
