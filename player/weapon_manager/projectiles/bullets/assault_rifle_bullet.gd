class_name RigidBodyBullet extends RigidBody3D


@export var damage := 1.0


func _on_body_entered(_body: Node):
	if 'hitbox' not in _body: #and not survives_collision:
		#print('colliding with ', _body, ' and destroying self')
		#print()
		queue_free()
