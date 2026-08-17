extends PlayerCombatTransitionState


### fn

## virtual
#
func _enter():
	process_mode = Node.PROCESS_MODE_INHERIT
	state_machine._start()
	if previous_state:
		_combat_status_changed.emit(weapon_manager.non_combat_status)

func _exit():
	process_mode = Node.PROCESS_MODE_DISABLED
	state_machine._stop()

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.equip_unequip):
		if weapon_manager_unavailable() and weapon_manager.current_weapon:
			_transition.emit(self, ArmedStates.armed_state)
