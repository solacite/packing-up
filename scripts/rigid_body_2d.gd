extends CharacterBody2D

var is_held = false  # Added this variable declaration

func _ready():
	# Add box to the "boxes" group so player can find it
	add_to_group("boxes")

func _physics_process(delta):
	if not is_held:
		# Only do collision-based movement when not being held
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			
			if collision.get_collider().has_method("is_player"):
				var player_velocity = collision.get_collider().velocity
				velocity = player_velocity
				
		move_and_slide()

func pickup():
	print("Box pickup() called")
	is_held = true
	# Disable collision when held
	set_collision_layer(0)
	set_collision_mask(0)

func drop():
	print("Box drop() called")
	is_held = false
	# Re-enable collision when dropped
	set_collision_layer(1)
	set_collision_mask(1)
	velocity = Vector2.ZERO
