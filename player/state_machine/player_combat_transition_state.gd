class_name PlayerCombatTransitionState extends State


# signal
@warning_ignore('unused_signal')
signal _combat_status_changed(_status: String)

# var
@export var state_machine: StateMachine
@export var combat_status: String
@export var weapon_manager: WeaponManager


### fn
##

# helper
func weapon_manager_available() -> bool:
	return weapon_manager.current_status == weapon_manager.WeaponManagerStatus.AVAILABLE

func weapon_manager_unavailable() -> bool:
	return weapon_manager.current_status == weapon_manager.WeaponManagerStatus.UNAVAILABLE
