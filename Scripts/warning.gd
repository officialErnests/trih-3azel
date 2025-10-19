extends Control


const to_load = "res://Scenes/game.tscn"
var main_game

func _ready() -> void:
	$Progression.text = "GET THE SHIT..."
	main_game = ResourceLoader.load_threaded_request(to_load)
	$Progression.text = "GOT THE SHIT..."
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	var progression = []
	var status = ResourceLoader.load_threaded_get_status(to_load, progression)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			$Progression.text = "{" + str(progression[0]) + "} LOADING CRAZY.XDD"
		ResourceLoader.THREAD_LOAD_LOADED:
			$Progression.text = "CRAZY.XDD LOADED [SPACE]"
			if Input.is_action_just_pressed("Jump"):
				get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(to_load))
		ResourceLoader.THREAD_LOAD_FAILED:
			$Progression.text = "FAILED TO LOAD ;-;"
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			$Progression.text = "AHHHHHHHHHHHH"
		_:
			$Progression.text = "Yeah.. idk what happened XD"
