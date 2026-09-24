extends Node


# signals
@warning_ignore('unused_signal')
signal _message(message: String)
@warning_ignore('unused_signal')
signal _speech(message: String)

@warning_ignore('unused_signal')
signal weapon_manager_started(weapon: Weapon, weapon_model: WeaponModel)
@warning_ignore('unused_signal')
signal weapon_manager_stopped()
@warning_ignore('unused_signal')
signal ammo_updated(weapon: Weapon)
@warning_ignore('unused_signal')
signal weapon_dropped(pickup: WeaponPickup)
