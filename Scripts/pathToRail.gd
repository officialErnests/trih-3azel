extends Path3D

var rail = preload("res://Scenes/rail.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	replace_rails()

func replace_rails():
	var cloned_rail = rail.instantiate()
	cloned_rail.curve = curve
	get_parent().add_child(cloned_rail)
	cloned_rail.global_position = global_position
