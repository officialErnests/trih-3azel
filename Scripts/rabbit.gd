extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
enum PLAYER_STATES {
	STILL,
	START_MOVE,
	FAST_RUN,
	QUICK_STOP,
	RUNNING,
	JUMP_START,
	FALL,
	TRICK,
	HIT_TROUGH,
	GRINDING,
	
	FAST_AIR,
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
@export var START_MOVE_SPEED_BOOST_MUL: float = 1
@export var START_MOVE_SPEED_BOOST_ADD: float = 1
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
#-HIT_TROUGH
@export_subgroup("HIT_TROUGH")
@export var HIT_TROUGH_TIME: float = 1
@export var HIT_TROUGH_PULL: float = 1
@export var HIT_TROUGH_SPEED_MUL: float = 1
@export var HIT_TROUGH_CLONES: int = 1
@export var HIT_TROUGH_DEBRIS_TIMER: int = 1
#-GRINDING
@export_subgroup("GRINDING")
@export var GRINDING_MIN_SPEED: int = 1
@export var GRINDING_ADDER: int = 1

# Internal variables
#OTHERS
var curent_player_state = PLAYER_STATES.STILL
var prev_player_state = curent_player_state
@onready var mesh = $MeshInstance3D
@onready var ground_raycast = $RayCast3D
#Collision with objects such as rail or blasstrough
#=Rails
var rail_processing = false
var touching_rail = null
#=Blasstrough
var blasstrough_processing = false
var blasstrough = null
var debriss = null
# Movement
#-START_MOVE
var start_move = 0
#-QUICK_STOP
var slow_down_timer = 0
var speed_before = 0
#-TRICK
var trick_time = 0
#-HIT_TROUGH
var hit_trough_timer = 0
var hit_trough_objects = []
#-GRINDING
var grind_position = 0
var rail_positioner = null
var start_speed = 0

func _init() -> void:
	Global.player = self

func _ready() -> void:
	slow_down_timer = QUICK_STOP_SLOW_DOWN_TIME
	start_move = START_MOVE_TIME
	debriss = get_parent().get_node("Debriss")
	
func _physics_process(delta: float) -> void:
	#Inputs
	var default_transform: Basis = Basis(Vector3.UP, movement_direction_node.rotation.y)
	if ground_raycast.is_colliding():
		print(default_transform)
		default_transform = Basis(ground_raycast.get_collision_normal(), movement_direction_node.rotation.y)
	var input_dir := Input.get_vector("Left", "Right", "Foward", "Backward")
	var direction := (default_transform * Vector3(
						input_dir.x,
						0,
						input_dir.y))
	$RayCast3D2.target_position = direction * 10
	var switch_state = curent_player_state != prev_player_state
	prev_player_state = curent_player_state

	#Processes player states
	blasstrough_processing = false
	rail_processing = false
	match curent_player_state:
		PLAYER_STATES.STILL:
			if Input.is_action_just_pressed("Jump"):
				# Switch states
				curent_player_state = PLAYER_STATES.JUMP_START

			if direction:
				add_velocity(delta, direction, STILL_SPEED)
				# Switch states
				curent_player_state = PLAYER_STATES.START_MOVE
			snapToGround()
			move_and_slide()
		
		PLAYER_STATES.START_MOVE:
			if switch_state:
				start_move = START_MOVE_TIME

			start_move -= delta
			
			if direction:
				add_velocity(delta, direction, START_MOVE_SPEED)
				multiplyVelocity2D(1 - (delta * (1.0 - (max(start_move, 0) / START_MOVE_TIME * 1.1)) * START_MOVE_SLOW_DOWN))
				if Input.is_action_just_pressed("Jump"):
					var prev_velocity = velocity.length()
					velocity.x = 0
					velocity.z = 0
					add_velocity(delta, direction, START_MOVE_SPEED_BOOST_MUL * prev_velocity + START_MOVE_SPEED_BOOST_ADD)
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

			railDetect()
			snapToGround()
			move_and_slide()

		PLAYER_STATES.FAST_RUN:
			if !is_on_floor():
				curent_player_state = PLAYER_STATES.FALL
			if direction:
				add_velocity(delta, direction, FAST_RUN_SPEED)
			else:
				if Input.is_action_just_pressed("Jump"):
						curent_player_state = PLAYER_STATES.TRICK
			multiplyVelocity2D(1 - (delta * FAST_RUN_SLOW_DOWN))
			if (velocity.length() < FAST_RUN_STOP_TRESHOLD):
				# Switch states
				curent_player_state = PLAYER_STATES.QUICK_STOP
			blastTroughDetect()
			snapToGround()
			railDetect()
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
			snapToGround()
			railDetect()
			move_and_slide()

		PLAYER_STATES.RUNNING:
			if !is_on_floor():
				curent_player_state = PLAYER_STATES.FALL
			if direction:
				add_velocity(delta, direction, RUNNING_SPEED)
				multiplyVelocity2D(1 - (delta * RUNNING_SLOW_DOWN))
			else:
				if Input.is_action_just_pressed("Jump"):
						curent_player_state = PLAYER_STATES.TRICK
			if (velocity.length() < RUNNING_TRESHOLD):
				# Switch states
				curent_player_state = PLAYER_STATES.START_MOVE
			blastTroughDetect()
			snapToGround()
			railDetect()
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
			railDetect()
			move_and_slide()
		
		PLAYER_STATES.FALL:
			velocity.y -= FALL_GRAVITY * delta
			if direction:
				add_velocity(delta, direction, FALL_SPEED)
			if is_on_floor():
				curent_player_state = PLAYER_STATES.START_MOVE
			blastTroughDetect()
			railDetect()
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
						if direction:
							var prev_velocity = velocity.length()
							velocity.x = 0
							velocity.z = 0
							add_velocity(delta, direction, START_MOVE_SPEED_BOOST_MUL * prev_velocity + START_MOVE_SPEED_BOOST_ADD)
						curent_player_state = PLAYER_STATES.JUMP_START
				else:
					# Switch states
					curent_player_state = PLAYER_STATES.FALL
			else:
				velocity.y -= JUMP_START_GRAVITY * delta
			railDetect()
			move_and_slide()

		PLAYER_STATES.HIT_TROUGH:
			blasstrough_processing = true
			if switch_state:
				hit_trough_timer = 0
				hit_trough_objects.append(blasstrough)
				for i in range(HIT_TROUGH_CLONES):
					var dublicate_hittrough = blasstrough.duplicate()
					hit_trough_objects.append(dublicate_hittrough)
					debriss.add_child(dublicate_hittrough)
					dublicate_hittrough.linear_velocity = velocity * Vector3(randf_range(0.1, 2), randf_range(0.1, 2), randf_range(0.1, 2))
					dublicate_hittrough.has_been_hit = true
					 
			hit_trough_timer += delta
			var shake_strenght = 0.5 * (1 - (hit_trough_timer / HIT_TROUGH_TIME))
			mesh.position = Vector3(randf_range(-shake_strenght, shake_strenght), randf_range(-shake_strenght, shake_strenght), randf_range(-shake_strenght, shake_strenght))
			for iter_objc in hit_trough_objects:
				iter_objc.global_position += (global_position - iter_objc.global_position) * delta * HIT_TROUGH_PULL * ((hit_trough_timer / HIT_TROUGH_TIME) ** 2 - 0.1)
			if hit_trough_timer >= HIT_TROUGH_TIME:
				velocity *= HIT_TROUGH_SPEED_MUL
				for iter_objc in hit_trough_objects:
					iter_objc.linear_velocity = velocity * Vector3(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
					iter_objc.constant_force = velocity
					iter_objc.delete_timer = HIT_TROUGH_DEBRIS_TIMER
				hit_trough_objects.clear()
				blasstrough_processing = false
				# Switch states
				blasstrough = null
				mesh.position = Vector3.ZERO
				curent_player_state = PLAYER_STATES.RUNNING

		PLAYER_STATES.GRINDING:
			if switch_state:
				grind_position = touching_rail.curve.get_closest_offset(touching_rail.to_local(global_position))
				rail_positioner = touching_rail.get_node("Follo_point")
				rail_positioner.v_offset = 0.5
				start_speed = max(velocity.length(), GRINDING_MIN_SPEED)

			start_speed += GRINDING_ADDER * delta
			rail_processing = true
			grind_position += delta * start_speed
			rail_positioner.progress = grind_position
			global_position = rail_positioner.global_position
			
			if Input.is_action_just_pressed("Jump"):
				# Switch states
				velocity = rail_positioner.transform.basis.y * start_speed
				touching_rail.debounce()
				rail_processing = false
				touching_rail = null
				curent_player_state = PLAYER_STATES.TRICK


			if rail_positioner.progress_ratio == 1:
				# Switch states
				velocity = rail_positioner.transform.basis.z * start_speed
				touching_rail.debounce()
				rail_processing = false
				touching_rail = null
				rail_positioner = null
				curent_player_state = PLAYER_STATES.FALL

		_:
			curent_player_state = PLAYER_STATES.START_MOVE
	
	if blasstrough != null and !blasstrough_processing:
		blasstrough = null

	if touching_rail != null and !rail_processing:
		touching_rail = null
		

func multiplyVelocity2D(slowness):
	Vector2(velocity.x, velocity.z)
	var vel_mul = Vector2(velocity.x, velocity.z) * slowness
	velocity.x = vel_mul.x
	velocity.z = vel_mul.y

func add_velocity(delta, direction, in_velocity):
	velocity.x += direction.x * in_velocity * delta * 10
	velocity.z += direction.z * in_velocity * delta * 10

func snapToGround():
	if !is_on_floor():
		if ground_raycast.is_colliding():
			velocity.y += (ground_raycast.get_collision_point().y - global_position.y) * 2
		else:
			curent_player_state = PLAYER_STATES.FALL

func blastTroughDetect():
	if blasstrough != null:
		blasstrough_processing = true
		blasstrough.hit.emit()
		# Switch states
		curent_player_state = PLAYER_STATES.HIT_TROUGH

func railDetect():
	if touching_rail != null:
		rail_processing = true
		# Switch states
		curent_player_state = PLAYER_STATES.GRINDING
