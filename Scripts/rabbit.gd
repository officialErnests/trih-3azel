extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
enum PLAYER_STATES {
	STILL,
	START_MOVE,
	START_DASH,
	RUNNING,
	STOPING,
	multiplyVelocity2D,
	HIT_TROUGH,
	FAST_RUN,
	GRINDING,
	JUMP_START,
	FALL,
	TRICK,
	WALL_RUN_R,
	WALL_RUN_L
}

#OTHERS
@export_category("Others")
@export var movement_direction_node: Node3D = Node3D.new()

#SETUP
@export_category("Movement")
#-STILL
@export_subgroup("Still")
@export var STILL_SPEED: float = 1
#-START_MOVE
@export_subgroup("START_MOVE")
@export var START_MOVE_TIME: float = 1
@export var START_MOVE_SPEED: float = 1
@export var START_MOVE_SLOW_DOWN: float = 1
@export var START_MOVE_FAST_SLOW_DOWN: float = 1
@export var START_MOVE_SPEED_BOOST: float = 1
#-FAST_RUN
@export_subgroup("FAST_RUN")
@export var FAST_RUN_SPEED: float = 2
@export var FAST_RUN_SLOW_DOWN: float = 2


# Internal variables
#OTHERS
var curent_player_state = PLAYER_STATES.STILL
#-START_MOVE
var start_move = START_MOVE_TIME
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
				add_velocity(delta, direction, STILL_SPEED)
				# Switch states
				curent_player_state = PLAYER_STATES.START_MOVE
			move_and_slide()
		
		PLAYER_STATES.START_MOVE:
			if !is_on_floor():
				curent_player_state = PLAYER_STATES.FALL

			if Input.is_action_just_pressed("Jump"):
				add_velocity(delta, direction, START_MOVE_SPEED_BOOST)
				# Switch states
				start_move = START_MOVE_TIME
				curent_player_state = PLAYER_STATES.FAST_RUN
			

			start_move -= delta
			if direction:
				add_velocity(delta, direction, START_MOVE_SPEED)
				multiplyVelocity2D(1 - (delta * (1.0 - (max(start_move, 0) / START_MOVE_TIME * 1.1)) * START_MOVE_SLOW_DOWN))
			else:
				multiplyVelocity2D(1 - (delta * max(start_move / START_MOVE_TIME + 1, 1) * START_MOVE_FAST_SLOW_DOWN))
				if abs(velocity.x) + abs(velocity.z) < 1:
					velocity.x = 0
					velocity.z = 0
					start_move = START_MOVE_TIME
					curent_player_state = PLAYER_STATES.STILL
			move_and_slide()

		PLAYER_STATES.FAST_RUN:
			if direction:
				add_velocity(delta, direction, FAST_RUN_SPEED)
				multiplyVelocity2D(1 - (delta * FAST_RUN_SLOW_DOWN))
			else:
				pass
			move_and_slide()
		_:
			pass


func multiplyVelocity2D(slowness):
	Vector2(velocity.x, velocity.z)
	var vel_mul = Vector2(velocity.x, velocity.z) * slowness
	velocity.x = vel_mul.x
	velocity.z = vel_mul.y

func add_velocity(delta, direction, in_velocity):
	velocity.x += direction.x * in_velocity * delta * 10
	velocity.z += direction.z * in_velocity * delta * 10
