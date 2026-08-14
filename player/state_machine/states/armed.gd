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
	if _event.is_action_pressed(InputManager.equip_unequip):
		if %WeaponManager.current_status == %WeaponManager.WeaponManagerStatus.AVAILABLE:
			_transition.emit(self, States.unarmed_state)

	if _event.is_action_pressed(InputManager.drop_weapon):
		var weapons: float = %WeaponManager.drop_weapon()

		if weapons == 0:
			_transition.emit(self, States.unarmed_state)
