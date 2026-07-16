extends PlayerCombatTransitionState


### fn

## virtual
#
func _enter():
	process_mode = Node.PROCESS_MODE_INHERIT
	state_machine._start()
	_combat_status_changed.emit(combat_status)

func _exit():
	process_mode = Node.PROCESS_MODE_DISABLED
	state_machine._stop()

func _state_input(_event: InputEvent):
	if _event.is_action_pressed(InputManager.equip):
		if %WeaponManager.current_status == %WeaponManager.WeaponManagerStatus.UNAVAILABLE:
			_transition.emit(self, States.armed_state)
