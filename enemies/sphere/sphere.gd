extends CharacterBody3D


@export var health := 5.0
@export var hitbox: Hitbox


func _on_hitbox_damage_take(_damage: float):
	health -= _damage
	if health <= 0:
		#print(self, ' is out of health. DIE!')
		#print()
		queue_free()
