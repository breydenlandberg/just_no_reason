class_name PlayerCombatTransitionState extends State


# signal
@warning_ignore('unused_signal')
signal _combat_status_changed(_status: String)

# var
@export var state_machine: StateMachine
@export var combat_status: String
