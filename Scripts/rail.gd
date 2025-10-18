extends Path3D

@export var segmen_leght = 1
@export var structure = 1
@onready var follow_point = $Follo_point
@onready var visual_boxes = $visual
@onready var copy_cube = $Cube
var collider = null
var path_lenght = 0
var can_detect = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	follow_point.progress_ratio = 1
	path_lenght = follow_point.progress

	collider = Area3D.new()
	collider.name = "Rail_collision"
	add_child(collider)

	for i in range(ceil(path_lenght / segmen_leght)):
		follow_point.progress = i * segmen_leght + segmen_leght / 2.0

		var visualiser_box = MeshInstance3D.new()
		visualiser_box.mesh = copy_cube.mesh
		visualiser_box.scale = Vector3(100, 100, 100)
		# visualiser_box.material_override = 
		# visualiser_box.scale = Vector3(100, 100, segmen_leght * 1000)
		visualiser_box.name = "vsBOX_" + str(i)
		visualiser_box.transform = follow_point.transform

		var box_collider = BoxShape3D.new()
		box_collider.size = Vector3(2, 2, segmen_leght)

		var collision_box = CollisionShape3D.new()
		collision_box.shape = box_collider
		collision_box.name = "clBOX_" + str(i)
		collision_box.transform = follow_point.transform

		visual_boxes.add_child(visualiser_box)
		collider.add_child(collision_box)

	collider.body_entered.connect(_on_rail_collision_body_entered)

func debounce():
	can_detect = false
	await get_tree().create_timer(0.5).timeout
	can_detect = true


func _on_rail_collision_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body.touching_rail == null and can_detect:
		body.touching_rail = self
