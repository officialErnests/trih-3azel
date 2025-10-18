extends Path3D

var rail = preload("res://Scenes/rail.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cloned_rail = rail.instantiate()
	get_parent().add_child.call_deferred(cloned_rail)
	cloned_rail.global_position = global_position
	cloned_rail.curve = curve