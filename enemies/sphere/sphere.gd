extends CharacterBody3D


@export var health := 5.0


func _on_hitbox_damage_take(_damage: float):
	health -= _damage
	if health <= 0:
		queue_free()
