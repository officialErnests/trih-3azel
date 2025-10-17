extends Camera3D

@export var stalk_distance = 10
var track_object: Node3D

@onready var nb_global_position = global_position

func _ready() -> void:
	track_object = get_parent()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fov = min(179, max(75, track_object.velocity.length() + 75))
	match track_object.curent_player_state:
		track_object.PLAYER_STATES.HIT_TROUGH:
			var hit_trough_timer = track_object.hit_trough_timer
			var track_position = track_object.global_position
			look_at(track_object.global_position)
			nb_global_position += (track_position - nb_global_position) * delta * min(max(nb_global_position.distance_to(track_position) - (stalk_distance * hit_trough_timer), -1), 1) * 4
			nb_global_position.y += (track_position.y - nb_global_position.y + hit_trough_timer) * delta
			global_position = nb_global_position
		_:
			var track_position = track_object.global_position + Vector3.UP
			look_at(track_object.global_position + Vector3.UP)
			nb_global_position += (track_position - nb_global_position) * delta * min(max(nb_global_position.distance_to(track_position) - stalk_distance, -1), 1) * 4
			if track_object.is_on_floor():
				nb_global_position.y += (track_position.y - nb_global_position.y - 0.5) * delta
			else:
				nb_global_position.y += (track_position.y - nb_global_position.y + 1) * delta * 4
			global_position = nb_global_position
