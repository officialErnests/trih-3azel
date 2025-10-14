extends Camera3D

@export var stalk_distance = 10

var previous_position = global_position
var glob_position = global_position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	glob_position += (glob_position - previous_position) * delta * 0.1
	previous_position = global_position
	glob_position = glob_position
