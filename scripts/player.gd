extends CharacterBody2D

# mvmt speeds
@export var walk_speed: float = 50.0
@export var run_speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 1200.0

# state and direction management
enum PlayerState { IDLE, WALK, RUN }
var current_state: PlayerState = PlayerState.IDLE
var last_input_vector: Vector2 = Vector2.ZERO

# anim
@onready var sprite: AnimatedSprite2D = $Sprite2D

func _ready():
	# check if sprite exists
	if not sprite:
		print("AnimatedSprite2D node not found")
	# set a default anim
	sprite.play("idle_front")

func _physics_process(delta):
	# get input once per frame
	var input_vector = get_input_vector()
	
	# debug output
	if input_vector != Vector2.ZERO:
		print("Input vector: ", input_vector)
		print("Velocity: ", velocity)
	
	handle_movement(delta, input_vector)
	update_state(input_vector)
	update_animations(input_vector)
	
	move_and_slide()

func handle_movement(delta: float, input_vector: Vector2):
	var target_speed = get_target_speed(input_vector)
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * target_speed, acceleration * delta)
		last_input_vector = input_vector
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func get_target_speed(input_vector: Vector2) -> float:
	if Input.is_action_pressed("run"):
		return run_speed
	else:
		return walk_speed

func update_state(input_vector: Vector2):
	if input_vector == Vector2.ZERO:
		current_state = PlayerState.IDLE
	elif Input.is_action_pressed("run"):
		current_state = PlayerState.RUN
	else:
		current_state = PlayerState.WALK

func get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	return input_vector.normalized()

func update_animations(input_vector: Vector2):
	if not sprite:
		return
	var direction_string = get_animation_direction_string(input_vector)
	var state_prefix = ""
	
	match current_state:
		PlayerState.IDLE:
			state_prefix = "idle"
		PlayerState.WALK:
			state_prefix = "walk"
		PlayerState.RUN:
			state_prefix = "run"
	
	# handle sprite flipping for left/right movement
	if direction_string == "_left":
		sprite.flip_h = true
		direction_string = "_right"  # Use right animations but flipped
	elif direction_string == "_right":
		sprite.flip_h = false
	
	var animation_name = state_prefix + direction_string
	sprite.play(animation_name)

func get_animation_direction_string(input_vector: Vector2) -> String:
	# keep last direction for idle state
	if input_vector == Vector2.ZERO:
		input_vector = last_input_vector
	if abs(input_vector.x) > abs(input_vector.y):
		if input_vector.x > 0:
			return "_right"
		else:
			return "_left"
	else:
		if input_vector.y > 0:
			return "_front"
		else:
			return "_back"

func is_player():
	return true
