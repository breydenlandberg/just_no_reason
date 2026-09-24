extends CharacterBody3D


@export var species: SphereSpecies = preload("uid://cpscedpei1tgq")
@export var mesh: MeshInstance3D
@export var hurtbox: Hurtbox

var _health := 1.0


### fn

## virtual
#
func _ready():
	if species:
		_health = species.health
		if species.appearance:
			mesh.material_override = species.appearance.duplicate()


## signal
#
func _on_hurtbox_damage_take(_damage: float):
	_health -= _damage
	if _health <= 0:
		#print(self, ' is out of health. DIE!')
		#print()
		queue_free()
