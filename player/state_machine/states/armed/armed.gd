extends PlayerCombatTransitionState


### fn

## virtual
#
func _enter():
	process_mode = Node.PROCESS_MODE_INHERIT
	state_machine._start()
	if previous_state:
		_combat_status_changed.emit(weapon_manager.combat_status)

func _exit():
	process_mode = Node.PROCESS_MODE_DISABLED
	state_machine._stop()

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.equip_unequip):
		if weapon_manager_available():
			_transition.emit(self, UnarmedStates.unarmed_state)

	if _event.is_action_pressed(InputManager.drop_weapon):
		var weapon_count: int = weapon_manager.drop_weapon()

		if weapon_count <= 0:
			_transition.emit(self, UnarmedStates.unarmed_state)
