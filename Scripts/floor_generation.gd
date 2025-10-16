@tool
extends Node3D

var block = preload("res://Scenes/gen_cube.tscn")
@export var grid_size: int:
	set(new_grid_size):
		grid_size = max(new_grid_size, 0)
		if Engine.is_editor_hint():
			size_update()

func _ready() -> void:
	size_update()
func size_update():
	if get_children():
		for iter_block in get_children():
			iter_block.queue_free()
	for x in range(grid_size):
		for z in range(grid_size):
			var temp_block = block.instantiate()
			temp_block.position.x = x * 2 - grid_size + 1
			temp_block.position.z = z * 2 - grid_size + 1
			temp_block.position.y = sin((temp_block.position.x + temp_block.position.z) / 20)
			temp_block.name = "Block" + str(grid_size) + str(x * grid_size + z)
			add_child(temp_block)
			temp_block.owner = get_tree().edited_scene_root
