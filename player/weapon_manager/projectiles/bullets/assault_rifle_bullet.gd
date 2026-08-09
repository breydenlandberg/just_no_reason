class_name RigidBodyBullet extends RigidBody3D


@export var damage := 1.0


func _on_body_entered(body: Node):
	queue_free()
