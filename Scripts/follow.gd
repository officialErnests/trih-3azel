extends Camera3D

@export var stalk_distance = 10
@export var track_object: Node3D
var velocity = 0
var avg_pos := Vector3.ZERO
@onready var nb_global_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	avg_pos += (track_object.global_position - avg_pos) * delta * 20
	match track_object.curent_player_state:
		track_object.PLAYER_STATES.HIT_TROUGH:
			fov = 90
			var hit_trough_timer = track_object.hit_trough_timer
			var track_position = track_object.global_position
			look_at(avg_pos)
			nb_global_position += (track_position - nb_global_position) * delta * min(max(nb_global_position.distance_to(track_position) - (stalk_distance * hit_trough_timer), -1), 1) * 4
			nb_global_position.y += (track_position.y - nb_global_position.y + hit_trough_timer) * delta
			global_position = nb_global_position
		_:
			velocity += (track_object.velocity.length() - velocity) * delta * 2
			fov = min(170, max(75, track_object.velocity.length() + 75 - velocity / 3))
			var track_position = track_object.global_position + Vector3.UP
			look_at(avg_pos + Vector3.UP)
			nb_global_position += (track_position - nb_global_position) * delta * min(max(nb_global_position.distance_to(track_position) - stalk_distance, -1), 1) * 10
			if track_object.is_on_floor():
				nb_global_position.y += (track_position.y - nb_global_position.y - 0.5) * delta
			else:
				nb_global_position.y += (track_position.y - nb_global_position.y + 1) * delta * 4
			global_position = nb_global_position
