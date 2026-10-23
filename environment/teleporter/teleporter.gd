class_name Teleporter extends Node3D


# vars
@export_group('Nodes')
@export var teleport_exit: Marker3D
@export var label: Label3D
@export_group('Settings')
@export var target_teleporter: Teleporter
@export var label_text := ''

var timeout := false


### fn

## virtual
#
func _ready():
	label.text = label_text


## public
#
func start_cooldown(duration := 2.0) -> void:
	timeout = true
	await get_tree().create_timer(duration).timeout
	timeout = false


## signals
#
func _on_teleporter_body_entered(body: Node3D) -> void:
	if timeout or not body is Player or not target_teleporter or not target_teleporter.teleport_exit:
		return

	target_teleporter.start_cooldown()
	body.global_position = target_teleporter.teleport_exit.global_position
