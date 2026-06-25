class_name MovementStats extends Resource


# @export var
@export var freefly_speed := 32.0
@export var time_to_jump_apex := 0.5
@export var time_to_land := 0.5
@export var jump_height := 2.0
@export var jump_distance := 6.0
@export var sprint_jump_distance := 18.0
@export var aim_jump_distance := 5.0
@export var acceleration := 100.0
@export var in_air_acceleration := 50.0
@export var sprint_duration := 6.0
@export var minimum_sprint_threshold := 1.5


### fn

## helper
#
func get_jump_gravity() -> float:
	var jump_gravity: float = (2 * jump_height) / pow(time_to_jump_apex, 2)
	return jump_gravity

func get_fall_gravity() -> float:
	var fall_gravity: float = (2 * jump_height) / pow(time_to_land, 2)
	return fall_gravity

func get_jump_velocity(gravity: float) -> float:
	var jump_velocity: float = gravity * time_to_jump_apex
	return jump_velocity

func get_velocity(_distance: float, jump_time: float) -> float:
	var velocity: float = _distance / jump_time
	return velocity
