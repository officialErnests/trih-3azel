extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
enum PLAYER_STATES {
	STILL,
	START_MOVE,
	START_DASH,
	QUICK_STOP,
	RUNNING,
	JUMP_START,
	FALL,
	TRICK,

	HIT_TROUGH,
	FAST_RUN,
	GRINDING,
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
@export var FAST_RUN_STOP_TRESHOLD: float = 2
#-QUICK_STOP
@export_subgroup("QUICK_STOP")
@export var QUICK_STOP_SLOW_DOWN_TIME: float = 1
@export var QUICK_STOP_SLOW_SPEED: float = 2
@export var QUICK_STOP_RELESE_MUL: float = 2
#-RUNNING
@export_subgroup("RUNNING")
@export var RUNNING_SPEED: float = 1
@export var RUNNING_SLOW_DOWN: float = 1
@export var RUNNING_TRESHOLD: float = 1
#-JUMP_START
@export_subgroup("JUMP_START")
@export var JUMP_START_FORCE: float = 1
@export var JUMP_START_SPEED: float = 1
@export var JUMP_START_GRAVITY: float = 1
@export var JUMP_START_SLOW_DOWN: float = 1
#-FALL
@export_subgroup("FALL")
@export var FALL_SPEED: float = 1
@export var FALL_GRAVITY: float = 1
#-TRICK
@export_subgroup("TRICK")
@export var TRICK_TIME: float = 1
@export var TRICK_FORCE: float = 1
@export var TRICK_SPEED: float = 1
@export var TRICK_GRAVITY: float = 1
@export var TRICK_SLOW_DOWN: float = 1

# Internal variables
#OTHERS
var curent_player_state = PLAYER_STATES.STILL
var prev_player_state = curent_player_state
#-START_MOVE
var start_move = 0
#-QUICK_STOP
var slow_down_timer = 0
var speed_before = 0
#-TRICK
var trick_time = 0

func _ready() -> void:
	slow_down_timer = QUICK_STOP_SLOW_DOWN_TIME
	start_move = START_MOVE_TIME
	
func _physics_process(delta: float) -> void:
	#Inputs
	var input_dir := Input.get_vector("Left", "Right", "Foward", "Backward")
	var direction := (transform.basis * Vector3(
						input_dir.x * sin(movement_direction_node.rotation.y + PI / 2) + input_dir.y * sin(movement_direction_node.rotation.y),
						0,
						input_dir.x * cos(movement_direction_node.rotation.y + PI / 2) + input_dir.y * cos(movement_direction_node.rotation.y))).normalized()
	
	var switch_state = curent_player_state != prev_player_state
	prev_player_state = curent_player_state
	# print(PLAYER_STATES.find_key(curent_player_state))
	#Processes player states
	match curent_player_state:
		PLAYER_STATES.STILL:
			if Input.is_action_just_pressed("Jump"):
				# Switch states
				curent_player_state = PLAYER_STATES.JUMP_START

			if direction:
				add_velocity(delta, direction, STILL_SPEED)
				# Switch states
				curent_player_state = PLAYER_STATES.START_MOVE

			if !is_on_floor():
				curent_player_state = PLAYER_STATES.FALL
			move_and_slide()
		
		PLAYER_STATES.START_MOVE:
			if switch_state:
				start_move = START_MOVE_TIME

			if !is_on_floor():
				curent_player_state = PLAYER_STATES.FALL

			start_move -= delta
			
			if direction:
				add_velocity(delta, direction, START_MOVE_SPEED)
				multiplyVelocity2D(1 - (delta * (1.0 - (max(start_move, 0) / START_MOVE_TIME * 1.1)) * START_MOVE_SLOW_DOWN))
				if Input.is_action_just_pressed("Jump"):
					var prev_velocity = velocity.length()
					velocity.x = 0
					velocity.z = 0
					add_velocity(delta, direction, START_MOVE_SPEED_BOOST * prev_velocity / 2)
					# Switch states
					curent_player_state = PLAYER_STATES.FAST_RUN
			else:
				multiplyVelocity2D(1 - (delta * max(start_move / START_MOVE_TIME + 1, 1) * START_MOVE_FAST_SLOW_DOWN))
				if Input.is_action_just_pressed("Jump"):
					curent_player_state = PLAYER_STATES.TRICK
				if abs(velocity.length()) < 1:
					velocity.x = 0
					velocity.z = 0
					# Switch states
					curent_player_state = PLAYER_STATES.STILL
			move_and_slide()

		PLAYER_STATES.FAST_RUN:
			if Input.is_action_just_pressed("Jump"):
					curent_player_state = PLAYER_STATES.TRICK
			if !is_on_floor():
				curent_player_state = PLAYER_STATES.FALL
			if direction:
				add_velocity(delta, direction, FAST_RUN_SPEED)
			multiplyVelocity2D(1 - (delta * FAST_RUN_SLOW_DOWN))
			if (velocity.length() < FAST_RUN_STOP_TRESHOLD):
				# Switch states
				curent_player_state = PLAYER_STATES.QUICK_STOP

			move_and_slide()
		
		PLAYER_STATES.QUICK_STOP:
			if !is_on_floor():
				curent_player_state = PLAYER_STATES.FALL
			if switch_state:
				speed_before = velocity.length()
				slow_down_timer = QUICK_STOP_SLOW_DOWN_TIME
			slow_down_timer -= delta
			var vel_mul = Vector2(velocity.x, velocity.z).normalized() * QUICK_STOP_SLOW_SPEED
			velocity.x = vel_mul.x
			velocity.z = vel_mul.y
			if Input.is_action_just_pressed("Jump"):
				var prev_velocity = velocity.length()
				velocity.x = 0
				velocity.z = 0
				add_velocity(delta, direction, prev_velocity * speed_before * QUICK_STOP_RELESE_MUL)
				# Switch states
				curent_player_state = PLAYER_STATES.RUNNING
			if slow_down_timer <= 0:
				# Switch states
				velocity = Vector3.ZERO
				curent_player_state = PLAYER_STATES.STILL
			move_and_slide()

		PLAYER_STATES.RUNNING:
			if Input.is_action_just_pressed("Jump"):
					curent_player_state = PLAYER_STATES.TRICK
			if !is_on_floor():
				curent_player_state = PLAYER_STATES.FALL
			if direction:
				add_velocity(delta, direction, RUNNING_SPEED)
				multiplyVelocity2D(1 - (delta * RUNNING_SLOW_DOWN))
			if (velocity.length() < RUNNING_TRESHOLD):
				# Switch states
				curent_player_state = PLAYER_STATES.START_MOVE
			move_and_slide()

		PLAYER_STATES.JUMP_START:
			if switch_state:
				velocity.y = JUMP_START_FORCE
			if direction:
				add_velocity(delta, direction, JUMP_START_SPEED)
				multiplyVelocity2D(1 - (delta * JUMP_START_SLOW_DOWN))
			velocity.y -= JUMP_START_GRAVITY * delta

			if velocity.y <= 0:
				# Switch states
				curent_player_state = PLAYER_STATES.FALL
			move_and_slide()
		
		PLAYER_STATES.FALL:
			velocity.y -= FALL_GRAVITY * delta
			if direction:
				add_velocity(delta, direction, FALL_SPEED)
			if is_on_floor():
				curent_player_state = PLAYER_STATES.START_MOVE
			move_and_slide()

		PLAYER_STATES.TRICK:
			if switch_state:
				trick_time = TRICK_TIME
				velocity.y = TRICK_FORCE
			if direction:
				add_velocity(delta, direction, TRICK_SPEED)
				multiplyVelocity2D(1 - (delta * TRICK_SLOW_DOWN))

			if velocity.y <= 0:
				if trick_time > 0:
					trick_time -= delta
					if Input.is_action_just_pressed("Jump"):
						# Switch states
						curent_player_state = PLAYER_STATES.JUMP_START
				else:
					# Switch states
					curent_player_state = PLAYER_STATES.FALL
			else:
				velocity.y -= JUMP_START_GRAVITY * delta

			move_and_slide()
		_:
			curent_player_state = PLAYER_STATES.START_MOVE


func multiplyVelocity2D(slowness):
	Vector2(velocity.x, velocity.z)
	var vel_mul = Vector2(velocity.x, velocity.z) * slowness
	velocity.x = vel_mul.x
	velocity.z = vel_mul.y

func add_velocity(delta, direction, in_velocity):
	velocity.x += direction.x * in_velocity * delta * 10
	velocity.z += direction.z * in_velocity * delta * 10
