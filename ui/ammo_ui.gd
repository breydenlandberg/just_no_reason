extends Control


# var
@export var current_ammo_label: Label
@export var reserve_ammo_label: Label
@export var ammo_graphic_container: GridContainer
@export var ammo_graphic: PackedScene


### fn

## virtual
#
func _ready():
	hide()
	# Clean placeholders used for development
	for child in ammo_graphic_container.get_children():
		child.queue_free()


## helper
#
func start(weapon: Weapon, _weapon_model: WeaponModel):
	update_ammo_ui(weapon)
	show()

func stop():
	hide()

func update_ammo_ui(weapon: Weapon):
	if not weapon:
		return

	update_ammo_text(weapon)
	update_ammo_graphic(weapon)

func update_ammo_text(weapon: Weapon):
	if weapon.current_ammo:
		current_ammo_label.text = str(weapon.current_ammo.count)
	else:
		current_ammo_label.text = '0'

	var reserve_ammo := 0

	if weapon.reserve_ammo:
		for ammo in weapon.reserve_ammo:
			reserve_ammo += ammo.count

	reserve_ammo_label.text = str(reserve_ammo)

func update_ammo_graphic(weapon: Weapon):
	var magazines: Array[Ammo] = []
	if weapon.current_ammo:
		magazines.append(weapon.current_ammo)
	if weapon.reserve_ammo:
		magazines.append_array(weapon.reserve_ammo)

	var children := ammo_graphic_container.get_children()

	# We only need to re-instantiate all the AmmoInstanceGraphic nodes if the number of magazines actually changes
	if children.size() != magazines.size():
		for child in children:
			child.queue_free()
		children.clear()

		for mag in magazines:
			var bar: ProgressBar = ammo_graphic.instantiate()
			ammo_graphic_container.add_child(bar)
			children.append(bar)

	for i in range(magazines.size()):
		children[i].setup(magazines[i].count, magazines[i].max_count)
