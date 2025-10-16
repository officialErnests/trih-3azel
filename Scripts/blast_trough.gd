extends RigidBody3D

signal hit
var has_been_hit = false

func _ready() -> void:
	hit.connect(hit_trough)
	

func hit_trough():
	has_been_hit = true

func _on_body_entered(body: Node) -> void:
	if !has_been_hit and body.is_in_group("Player") and body.curent_player_state == body.PLAYER_STATES.FAST_RUN:
		body.blasstrough = self