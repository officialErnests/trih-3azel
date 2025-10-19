extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(5).timeout
	$TextShadow6.queue_free()
	await get_tree().create_timer(0.8).timeout
	$TextShadow5.queue_free()
	await get_tree().create_timer(0.8).timeout
	$TextShadow4.queue_free()
	await get_tree().create_timer(0.8).timeout
	$TextShadow3.queue_free()
	await get_tree().create_timer(0.8).timeout
	$TextShadow2.queue_free()
	await get_tree().create_timer(0.8).timeout
	$TextShadow.queue_free()
	await get_tree().create_timer(0.8).timeout
	$Text.queue_free()
	queue_free()

var a = 0
func _process(delta: float) -> void:
	a += delta
	var b = 0
	if Input.is_action_just_pressed("Jump"):
		$TextShadow6.queue_free()
		$TextShadow5.queue_free()
		$TextShadow4.queue_free()
		$TextShadow3.queue_free()
		$TextShadow2.queue_free()
		$TextShadow.queue_free()
		$Text.queue_free()
		queue_free()

	for child in get_children():
		b += 1
		child.position.x += sin(a * 2 + b / 2.0) * 0.1
