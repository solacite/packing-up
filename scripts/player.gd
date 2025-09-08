extends CharacterBody2D

# mvmt speeds
@export var walk_speed: float = 50.0
@export var run_speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 1200.0

# pickup system
@export var pickup_range: float = 50.0
var held_box = null
var nearby_boxes = []

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
	
	# Handle pickup/drop input
	handle_pickup_input()
	
	handle_movement(delta, input_vector)
	update_state(input_vector)
	update_animations(input_vector)
	
	# Update held box position if we have one
	if held_box:
		held_box.global_position = global_position
	
	# Find nearby boxes
	find_nearby_boxes()
	
	move_and_slide()

func handle_pickup_input():
	if Input.is_action_just_pressed("pickup"):  # You'll need to define this action
		print("Pickup input detected")
		
		if held_box:
			# Drop the box
			print("Attempting to drop box")
			drop_box()
		else:
			# Try to pick up a box
			print("Attempting to pick up box")
			pickup_nearest_box()

func find_nearby_boxes():
	nearby_boxes.clear()
	var boxes = get_tree().get_nodes_in_group("boxes")
	
	for box in boxes:
		if box != held_box:  # Don't include the box we're already holding
			var distance = global_position.distance_to(box.global_position)
			if distance <= pickup_range:
				nearby_boxes.append(box)

func pickup_nearest_box():
	if nearby_boxes.is_empty():
		print("No boxes nearby to pick up")
		return
	
	# Find the closest box
	var closest_box = null
	var closest_distance = INF
	
	for box in nearby_boxes:
		var distance = global_position.distance_to(box.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_box = box
	
	if closest_box:
		print("Picking up box at distance: ", closest_distance)
		held_box = closest_box
		held_box.pickup()

func drop_box():
	if held_box:
		print("Dropping box")
		held_box.drop()
		held_box = null

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
	
	# Handle sprite flipping for left/right movement
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
