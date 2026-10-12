class_name AmmoInstanceGraphic extends ProgressBar


# vars
@export var current_ammo_style: StyleBoxFlat
@export var reserve_ammo_style: StyleBoxFlat
@export var low_ammo_style: StyleBoxFlat


### fn

## helper
#
func setup(count: int, max_count: int, is_current := false) -> void:
	max_value = max_count
	value = count
	if is_current:
		if max_count > 0 and (float(count) / float(max_count) < 0.34): # if ammo is ~1/3 full or less
			add_theme_stylebox_override('fill', low_ammo_style)
		else:
			add_theme_stylebox_override('fill', current_ammo_style)
	else:
		add_theme_stylebox_override('fill', reserve_ammo_style)
