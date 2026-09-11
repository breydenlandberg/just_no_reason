extends Control


# var
@export var current_ammo_label: Label
@export var reserve_ammo_label: Label
@export var ammo_graphic_container: GridContainer
@export var ammo_graphic: PackedScene


### fn

## helper
#
func start(weapon: Weapon, _weapon_model: WeaponModel):
	update_ammo_text(weapon)
	update_ammo_graphic(weapon)
	show()

func stop():
	hide()

func update_ammo_text(weapon: Weapon):
	if not weapon:
		return

	if weapon.current_ammo:
		current_ammo_label.text = str(weapon.current_ammo.ammo_count)
	else:
		current_ammo_label.text = '0'

	var reserve_ammo := 0

	for ammo in weapon.reserve_ammo:
		reserve_ammo += ammo.ammo_count

	reserve_ammo_label.text = str(reserve_ammo)

func update_ammo_graphic(weapon: Weapon):
	if not weapon:
		return

	for child in ammo_graphic_container.get_children():
		#ammo_graphic_container.remove_child(child)
		child.queue_free()

	if weapon.current_ammo:
		ammo_graphic_container.add_child(ammo_graphic.instantiate())

	for ammo in weapon.reserve_ammo:
		ammo_graphic_container.add_child(ammo_graphic.instantiate())
