extends Path3D

@export var segmen_leght = 1
@onready var follow_point = $Follo_point
@onready var visual_boxes = $visual
var collider = null
var path_lenght = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	follow_point.progress_ratio = 1
	path_lenght = follow_point.progress
	
	collider = Area3D.new()
	collider.name = "Rail_collision"
	add_child(collider)

	for i in range(ceil(path_lenght / segmen_leght)):
		follow_point.progress = i * segmen_leght + segmen_leght / 2.0

		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(0.25, 0.25, segmen_leght)

		var visualiser_box = MeshInstance3D.new()
		visualiser_box.mesh = box_mesh
		visualiser_box.name = "vsBOX_" + str(i)
		visualiser_box.transform = follow_point.transform

		var box_collider = BoxShape3D.new()
		box_mesh.size = Vector3(0.25, 0.25, segmen_leght)

		var collision_box = CollisionShape3D.new()
		collision_box.shape = box_collider
		collision_box.name = "clBOX_" + str(i)
		collision_box.transform = follow_point.transform

		visual_boxes.add_child(visualiser_box)
		collider.add_child(collision_box)

	collider.body_entered.connect(_on_rail_collision_body_entered)


func _on_rail_collision_body_entered(body: Node3D) -> void:
	print(body.name)
	# if body.is_in_group("Player"):
