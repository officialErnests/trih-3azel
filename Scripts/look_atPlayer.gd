extends Node3D

func _process(delta: float) -> void:
	look_at(Global.player.global_position)
