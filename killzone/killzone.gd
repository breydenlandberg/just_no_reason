extends Area3D


# var
@export var player: CharacterBody3D

@onready var timer := $Timer


### fn

## signals
#
func _on_body_entered(body: CharacterBody3D):
	if body == player:
		SignalBus._message.emit('You killed yourself')
		timer.start()
	else:
		SignalBus._message.emit(str(body) + ' killed themself')
		body.queue_free()
		print('Queue freeing the node: ', body)

	print('\n')

func _on_timer_timeout():
	InteractManager.reset()
	get_tree().reload_current_scene()
