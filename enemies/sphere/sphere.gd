@tool
extends CharacterBody3D


@export var species: SphereSpecies = preload("uid://cpscedpei1tgq"):
	set(value):
		species = value
		_update_visuals()
@export var mesh: MeshInstance3D
@export var hurtbox: Hurtbox

var _health := 1.0


### fn

## virtual / private
#
func _ready():
	_update_visuals()

	if Engine.is_editor_hint():
		return

	if species:
		_health = species.health

func _update_visuals() -> void:
	# if not is_inside_tree() is there to prevent crashing. This occurs because the species set() function is called
	# immediately right after the scene is _init(). At this point, the node isn't inside the tree, so let's not do a visual update
	# and prevent crash. _ready() will call _update_visuals() when the time is right. Making changes to the species are reflected
	# in editor because we are inside tree at that point.
	if not is_inside_tree() or not mesh:
		return

	if species:
		if species.appearance:
			mesh.material_override = species.appearance if Engine.is_editor_hint() else species.appearance.duplicate()
		else:
			mesh.material_override = null
		scale = Vector3.ONE * species.scale
	else:
		mesh.material_override = null
		scale = Vector3.ONE


## signal
#
func _on_hurtbox_damage_take(_damage: float):
	_health -= _damage
	if _health <= 0:
		#print(self, ' is out of health. DIE!')
		#print()
		queue_free()
