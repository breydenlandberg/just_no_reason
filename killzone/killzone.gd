extends Area3D


# var

# @onready
@onready var timer := $Timer
@onready var player: CharacterBody3D =  $'../Player' # ??? @export ? what about non-player entities


### fn

## signals
#
# CharacterBody3D?
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
	#EntityManager.reset()
	InteractManager.reset()
	get_tree().reload_current_scene()
