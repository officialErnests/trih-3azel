@tool
extends Node3D

var show_box = null
@export var spawn_size: Vector3:
	set(new_spawn_size):
		if show_box != null:
			show_box.queue_free()
		spawn_size = new_spawn_size
		if Engine.is_editor_hint():
			show_box = show_bounding_box()
@export var spawn_obj: PackedScene
@export var spawn_size_min: float
@export var spawn_size_max: float
@export var spawn_amount: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Engine.is_editor_hint():
		visible = true
		for x in range(spawn_amount):
			var instance = spawn_obj.instantiate()
			instance.position = Vector3(randf_range(spawn_size.x / -2, spawn_size.x / 2),
										randf_range(spawn_size.y / -2, spawn_size.y / 2),
										randf_range(spawn_size.z / -2, spawn_size.z / 2))
			instance.scale = Vector3.ONE * randf_range(spawn_size_min, spawn_size_max)
			add_child(instance)


func show_bounding_box():
	var new_box = MeshInstance3D.new()
	new_box.mesh = BoxMesh.new()
	new_box.scale = spawn_size
	new_box.transparency = 0.9
	add_child(new_box)
	return new_box
