extends RigidBody3D

signal hit
var has_been_hit = false
var delete_timer = -1
@onready var cube = $Cube

func _ready() -> void:
	hit.connect(hit_trough)
	

func hit_trough():
	has_been_hit = true
	physics_material_override.bounce = 1

func _process(delta: float) -> void:
	if delete_timer != -1:
		delete_timer -= delta
		cube.scale = Vector3.ONE * (delete_timer / 5 * 100)
		if delete_timer <= 0:
			queue_free()
			return
func _on_body_entered(body: Node) -> void:
	if !has_been_hit and body.is_in_group("Player") and body.blasstrough == null:
		body.blasstrough = self
