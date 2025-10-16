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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_bounding_box():
	var new_box = MeshInstance3D.new()
	new_box.mesh = BoxMesh.new()
	new_box.scale = spawn_size
	add_child(new_box)
	return new_box
