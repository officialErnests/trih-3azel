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

@export_category("Others")
@export var movement_direction_node: Node3D = Node3D.new()

@export_category("Movement")
#SETUP
#-STILL
@export_subgroup("Still")
@export var STILL_SPEED: float = 20
#-START_MOVE
@export_subgroup("START_MOVE")
@export var START_MOVE_TIME = 0.5
@export var START_MOVE_SPEED = 2
@export var START_MOVE_SLOW_DOWN = 20


# Internal variables
var start_move = -1
var curent_player_state = PLAYER_STATES.STILL
func _physics_process(delta: float) -> void:
	#Inputs
	var input_dir := Input.get_vector("Left", "Right", "Foward", "Backward")
	var direction := (transform.basis * Vector3(
						input_dir.x * sin(movement_direction_node.rotation.y + PI / 2) + input_dir.y * sin(movement_direction_node.rotation.y),
						0,
						input_dir.x * cos(movement_direction_node.rotation.y + PI / 2) + input_dir.y * cos(movement_direction_node.rotation.y))).normalized()
	
	#Processes player states
	match curent_player_state:
		PLAYER_STATES.STILL:
			if direction:
				curent_player_state = PLAYER_STATES.START_MOVE
				add_velocity(delta, direction, STILL_SPEED)
			move_and_slide()
		
		PLAYER_STATES.START_MOVE:
			if (start_move == -1):
				start_move = START_MOVE_TIME
			else:
				start_move -= delta
			if direction:
				add_velocity(delta, direction, START_MOVE_SPEED)
			else:
				if abs(velocity.x + velocity.z) < 1:
					velocity.x = 0
					velocity.z = 0
					curent_player_state = PLAYER_STATES.STILL
			Vector2(velocity.x, velocity.z)
			velocity.x = move_toward(velocity.x, 0, START_MOVE_SLOW_DOWN * delta * max(start_move / START_MOVE_TIME + 1, 1))
			velocity.z = move_toward(velocity.z, 0, START_MOVE_SLOW_DOWN * delta * max(start_move / START_MOVE_TIME + 1, 1))
			move_and_slide()
		_:
			pass
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

func add_velocity(delta, direction, in_velocity):
	velocity.x += direction.x * in_velocity * delta * 10
	velocity.z += direction.z * in_velocity * delta * 10