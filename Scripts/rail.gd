extends Path3D

@export var segmen_leght = 1
@export var structure = 1
@onready var follow_point = $Follo_point
@onready var visual_boxes = $visual
var collider = null
var path_lenght = 0
var can_detect = true
var cube = preload("res://Scenes/plz_be_faster.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	follow_point.progress_ratio = 1
	path_lenght = follow_point.progress

	collider = Area3D.new()
	collider.name = "Rail_collision"

	for i in range(ceil(path_lenght / segmen_leght)):
		follow_point.progress = i * segmen_leght + segmen_leght / 2.0

		var visualiser_box = cube.instantiate()
		visualiser_box.name = "vsBOX_" + str(i)
		visualiser_box.transform = follow_point.transform

		var box_collider = BoxShape3D.new()
		box_collider.size = Vector3(2, 4, segmen_leght)

		var collision_box = CollisionShape3D.new()
		collision_box.shape = box_collider
		collision_box.name = "clBOX_" + str(i)
		collision_box.transform = follow_point.transform

		visual_boxes.add_child(visualiser_box)
		visualiser_box.scale = Vector3(25, 25, segmen_leght * 100)

		collider.add_child(collision_box)

		if i % 20 == 0 or i == 0 or i == ceil(path_lenght / segmen_leght) - 1:
			var support_box = cube.instantiate()
			support_box.name = "vsBOX_" + str(i)
			support_box.transform = follow_point.transform
			support_box.position -= follow_point.transform.basis.y * 10.25
			visual_boxes.add_child(support_box)
			support_box.scale = Vector3(25, 1000, 25)
			
			for e in range(ceil((follow_point.position.y + 40) / 20)):
				var base_support_box = cube.instantiate()
				base_support_box.name = "vsBOX_" + str(i)
				base_support_box.transform = follow_point.transform
				base_support_box.position -= follow_point.transform.basis.y * 20
				base_support_box.position.y -= 10 + 20 * e
				base_support_box.rotation_degrees = Vector3(0, 0, 0)
				visual_boxes.add_child(base_support_box)
				base_support_box.scale = Vector3(25, 1000, 25)

	add_child(collider)
	collider.body_entered.connect(_on_rail_collision_body_entered)

func debounce():
	can_detect = false
	await get_tree().create_timer(0.5).timeout
	can_detect = true


func _on_rail_collision_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body.touching_rail == null and can_detect:
		body.touching_rail = self
