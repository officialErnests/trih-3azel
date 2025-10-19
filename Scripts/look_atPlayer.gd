extends Node3D

var rotation_x = 0
var rotation_y = 0
var rotation_z = 0
var speed = randf() + 0.5
func _process(delta: float) -> void:
	look_at(Global.player.global_position)
	$CubeMesh.rotation += (Vector3(rotation_x, rotation_y, rotation_z) - $CubeMesh.rotation) * delta * speed
	# print(Vector3(rotation_x, rotation_y, rotation_z) - $CubeMesh.rotation)
	if (Vector3(rotation_x, rotation_y, rotation_z) - $CubeMesh.rotation).length() <= 0.01:
		match randi_range(0, 2):
			0:
				rotation_x += PI * (randi_range(0, 1) - 0.5)
			1:
				rotation_y += PI * (randi_range(0, 1) - 0.5)
			2:
				rotation_z += PI * (randi_range(0, 1) - 0.5)
