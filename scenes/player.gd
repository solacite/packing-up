extends CharacterBody2D

# mvmt speeds
@export var walk_speed: float = 150.0
@export var run_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# state management
enum PlayerState { IDLE, WALK, RUN }
var current_state: PlayerState = PlayerState.IDLE

# anim
@onready var sprite: AnimatedSprite2D = $Sprite2D

func _ready():
	# check if sprite exists
	if not sprite:
		print("AnimatedSprite2D node not found")

func _physics_process(delta):
	handle_movement(delta)
	update_state()
	update_animations()
	move_and_slide()

func handle_movement(delta):
	var input_vector = Vector2.ZERO
	
	# get input direction
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	
	# normalize diagonal movement
	input_vector = input_vector.normalized()
	
	var target_speed = get_target_speed(input_vector)
	
	if input_vector != Vector2.ZERO:
		# accelerate towards target velocity
		velocity = velocity.move_toward(input_vector * target_speed, acceleration * delta)
		
		# flip sprite for left mvmt (when using right anim)
		if sprite and abs(input_vector.x) > abs(input_vector.y):
			sprite.flip_h = input_vector.x < 0
		elif sprite:
			sprite.flip_h = false  # Ddon't flip for vertical movement
	else:
		# apply friction when not moving
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func get_target_speed(input_vector: Vector2) -> float:
	if input_vector == Vector2.ZERO:
		return 0.0
	
	# check if holding run
	if Input.is_action_pressed("run"):
		return run_speed
	else:
		return walk_speed

func update_state():
	var speed = velocity.length()
	var input_vector = get_input_vector()
	var target_speed = get_target_speed(input_vector)
	
	if speed < 10: # idle threshold
		current_state = PlayerState.IDLE
	elif target_speed >= run_speed - 10: # close to run speed
		current_state = PlayerState.RUN
	else:
		current_state = PlayerState.WALK

func get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	return input_vector.normalized()

func update_animations():
	if not sprite:
		return
	
	var direction = get_animation_direction()
	var state_prefix = ""
	
	match current_state:
		PlayerState.IDLE:
			state_prefix = "idle_"
		PlayerState.WALK:
			state_prefix = "walk_"
		PlayerState.RUN:
			state_prefix = "run_"
	
	var animation_name = state_prefix + direction
	sprite.play(animation_name)

func get_animation_direction() -> String:
	var input_vector = get_input_vector()
	
	# if not moving, keep the last direction or default to front
	if input_vector == Vector2.ZERO:
		# keep current anim direction or default to front
		if sprite.animation != "":
			var current_animation = sprite.animation
			if current_animation.ends_with("_back"):
				return "back"
			elif current_animation.ends_with("_right"):
				return "right"
			elif current_animation.ends_with("_front"):
				return "front"
		return "front"  # default to front
	
	# determine direction based on input (prioritize vertical movement)
	if abs(input_vector.y) > abs(input_vector.x):
		if input_vector.y > 0:
			return "front"  # moving down
		else:
			return "back"   # moving up
	else:
		return "right"      # moving left or right

func is_moving() -> bool:
	return velocity.length() > 10

func get_movement_direction() -> Vector2:
	if velocity.length() > 10:
		return velocity.normalized()
	return Vector2.ZERO
