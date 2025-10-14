extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
enum PLAYER_STATES {
	STILL,
	START_MOVE,
	START_DASH,
	RUNNING,
	STOPING,
	SLOWDOWN,
	HIT_TROUGH,
	FAST_RUN,
	GRINDING,
	JUMP_START,
	FALL,
	TRICK,
	WALL_RUN_R,
	WALL_RUN_L
}

#SETUP
#-STILL
const STILL_SPEED = 10
#-START_MOVE
const START_MOVE_TIME = 1
const START_MOVE_SPEED = 1
const START_MOVE_SLOW_DOWN = 1


# Internal variables
var start_move = -1
var curent_player_state = PLAYER_STATES.STILL
func _physics_process(delta: float) -> void:
	#Gets input
	var input_dir := Input.get_vector("Left", "Right", "Foward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	match curent_player_state:
		PLAYER_STATES.STILL:
			if direction:
				curent_player_state = PLAYER_STATES.START_MOVE
				velocity.x = direction.x * STILL_SPEED * delta * 10
				velocity.z = direction.z * STILL_SPEED * delta * 10
		
		PLAYER_STATES.START_MOVE:
			if (start_move == -1):
				start_move = START_MOVE_TIME
			else:
				start_move -= delta
			if direction:
				velocity.x += direction.x * START_MOVE_SPEED * delta * 10
				velocity.z += direction.z * START_MOVE_SPEED * delta * 10
			else:
				if abs(velocity.x + velocity.z) < 1:
					velocity.x = 0
					velocity.z = 0
					curent_player_state = PLAYER_STATES.STILL
				velocity.x = move_toward(velocity.x, 0, START_MOVE_SLOW_DOWN * delta)
				velocity.z = move_toward(velocity.z, 0, START_MOVE_SLOW_DOWN * delta)
		_:
			pass
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	move_and_slide()
