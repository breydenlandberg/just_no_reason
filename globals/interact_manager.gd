extends Node3D


# var
var current_interaction: Interaction
var executed_interactions: Array[Interaction]
var interactions: Array[Interaction]
var interact_label: Label
var player: CharacterBody3D


### fn

## helper
#
func erase(interaction: Interaction):
	interactions.erase(interaction)
	current_interaction = interactions.front()

	print('InteractManager.erase()')
	print('interactions: ', interactions)
	print('current_interaction: ', current_interaction)
	print('\n')

func execute_current_interaction():
	if current_interaction:
		var current_interaction_temp = current_interaction

		if current_interaction_temp and not executed_interactions.has(current_interaction_temp):
			print('InteractManager.execute_current_interaction() before ', current_interaction_temp.duration, 's timeout')
			print('interactions: ', interactions)
			print('current_interaction: ', current_interaction)
			print('\n')

			match current_interaction_temp.type:
				'TEXT':
					current_interaction_temp.get_node('InteractLabel').text = current_interaction.value

			executed_interactions.push_front(current_interaction_temp)

			print('executed_interactions: ', executed_interactions)
			print('\n')

			var next_interaction_i = interactions.find(current_interaction_temp) + 1
			if next_interaction_i < interactions.size():
				var next_interaction = interactions[next_interaction_i]

				print('Current interaction ', current_interaction_temp, ' in an executed state, switching current_interaction to: ', next_interaction)
				print('\n')

				current_interaction = next_interaction

			update_interact_label()

			await get_tree().create_timer(current_interaction_temp.duration).timeout

			print('Finished interaction: ', current_interaction_temp)
			print('\n')

			if is_instance_valid(current_interaction_temp):
				executed_interactions.remove_at(executed_interactions.find(current_interaction_temp))

				print('executed_interactions: ', executed_interactions)
				print('\n')

				match current_interaction_temp.type:
					'TEXT':
						current_interaction_temp.get_node('InteractLabel').text = ''

				if current_interaction and interactions:
					var first_not_executed_i: int
					for i in interactions.size():
						if not executed_interactions.has(interactions[i]):
							first_not_executed_i = i
							break

					print('Switching current_interaction to: ', interactions[first_not_executed_i])
					print('\n')

					current_interaction = interactions[first_not_executed_i]
					update_interact_label()

				print('InteractManager.execute_current_interaction() after ', current_interaction_temp.duration, 's timeout')
				print('interactions: ', interactions)
				print('current_interaction: ', current_interaction)
				print('\n')
	else:
		pass
		print('No current interaction')
		print('\n')

func push_front(interaction: Interaction):
	interactions.push_front(interaction)
	current_interaction = interactions.front()

	print('InteractManager.push_front()')
	print('interactions: ', interactions)
	print('current_interaction: ', current_interaction)
	print('\n')

func reset():
	current_interaction = null
	executed_interactions.clear()
	interactions.clear()
	interact_label = null
	player = null

	print('INTERACT MANAGER')
	print('reset()')
	print('==========')
	print('current_interaction: ', current_interaction)
	print('executed_interactions: ', executed_interactions)
	print('interactions: ', interactions)
	print('interact_label: ', interact_label)
	print('player: ', player)
	print('\n')

func set_player(player_param: CharacterBody3D):
	player = player_param
	interact_label = player.get_node('Interact/InteractLabel')

	print('INTERACT MANAGER')
	print('set_player()')
	print('==========')
	print('current_interaction: ', current_interaction)
	print('executed_interactions: ', executed_interactions)
	print('interactions: ', interactions)
	print('interact_label: ', interact_label)
	print('player: ', player)
	print('\n')

func update_interact_label():
	if current_interaction and not executed_interactions.has(current_interaction):
		interact_label.text = current_interaction.label
	else:
		interact_label.text = ''
