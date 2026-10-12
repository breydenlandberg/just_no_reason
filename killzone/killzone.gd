extends Area3D


# vars
@onready var timer := $Timer


### fn

## signals
#
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		SignalBus._message.emit('You killed yourself')
		timer.start()
	else:
		SignalBus._message.emit(str(body) + ' killed themself')
		body.queue_free()
		print('Queue freeing the node: ', body)

	print('\n')

func _on_timer_timeout() -> void:
	InteractManager.reset()
	get_tree().reload_current_scene()
