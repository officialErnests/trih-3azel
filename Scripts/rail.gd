extends Path3D

@export var segmen_leght = 1
@onready var follow_point = $Follo_point
var path_lenght = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	follow_point.progress_ratio = 1
	path_lenght = follow_point.progress
	for i in range(ceil(path_lenght / segmen_leght)):
		follow_point.progress = i * segmen_leght + segmen_leght / 2.0
		var visualiser_box = MeshInstance3D.new()
		visualiser_box.mesh = BoxMesh.new()
		visualiser_box.name = "vsBOX_" + str(i)
		visualiser_box.transform = follow_point.transform
		visualiser_box.mesh.size.z = segmen_leght
		add_child(visualiser_box)
