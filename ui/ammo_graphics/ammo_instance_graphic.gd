class_name AmmoInstanceGraphic extends ProgressBar


@export var current_ammo_style: StyleBoxFlat
@export var reserve_ammo_style: StyleBoxFlat


func setup(count: int, max_count: int, is_current := false):
	max_value = max_count
	value = count
	if is_current:
		add_theme_stylebox_override('fill', current_ammo_style)
	else:
		add_theme_stylebox_override('fill', reserve_ammo_style)
