extends Control


# var
@onready var current_ammo_label: Label = $HBoxContainer/CurrentAmmo
@onready var reserve_ammo_label: Label = $HBoxContainer/ReserveAmmo


### fn

## helper
#
func start(weapon: Weapon):
	update_ammo_text(weapon)
	show()

func stop():
	hide()

func update_ammo_text(weapon: Weapon):
	if weapon.current_ammo:
		current_ammo_label.text = str(weapon.current_ammo.ammo_count)
	else:
		current_ammo_label.text = '0'

	var reserve_ammo := 0

	for ammo in weapon.reserve_ammo:
		reserve_ammo += ammo.ammo_count

	reserve_ammo_label.text = str(reserve_ammo)
