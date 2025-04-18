extends CharacterBody2D

@export var rotation_speed: float = 4.0
@export var current_speed: float = 0.0
@export var acceleration: float = 100.0
@export var deceleration: float = 80.0
@export var max_speed: float = 200.0
@onready var boat_sprite: AnimatedSprite2D = $boat_sprite
@onready var speed_label: Label = $UI/SpeedLabel
@onready var speed_gauge: ProgressBar = $UI/SpeedGauge
@export var cannonball_scene: PackedScene
@onready var cannon_left = $CannonLeft
@onready var cannon_right = $CannonRight




#This function handles all  PHYSICS processes per frame
func _physics_process(delta: float) -> void:
#--- Rotation ---
	var speed_ratio = clamp(current_speed / max_speed, 0.0, 1.0)
	var effective_rotation_speed = rotation_speed * speed_ratio
	if Input.is_action_pressed("ui_left"):
		rotation -= (rotation_speed * (current_speed / max_speed)) * delta
	elif Input.is_action_pressed("ui_right"):
		rotation += (rotation_speed * (current_speed / max_speed)) * delta

# --- Acceleration ---
	if Input.is_action_pressed("ui_up"):
		current_speed += acceleration * delta
		current_speed = clamp(current_speed, 0, max_speed)
	elif Input.is_action_pressed("ui_down"):
		current_speed -= deceleration * delta
		current_speed = max(current_speed, 0)


# --- Shooting ---

	# --- Set velocity based on current speed and rotation ---
	velocity = Vector2.UP.rotated(rotation) * current_speed
	move_and_slide()


# === This function handles all NONPHYSICS processes per frame ===
func _process(delta: float) -> void:
	# --- changes sprite based on direction ---
	update_sprite_direction()
	boat_sprite.rotation = -rotation  # cancels out visual rotation. without it, the boat looks like its kickflipping
	
	
	if Input.is_action_just_pressed("fire_left"):
		fire_cannon(cannon_left, true)
	if Input.is_action_just_pressed("fire_right"):
		fire_cannon(cannon_right, false)
	
	
	# -- UI --
	var display_speed = int(current_speed)
	speed_label.text = "Speed: " + str(display_speed)
	speed_gauge.value = current_speed

	
func update_sprite_direction():
	var total_directions = 16
	var angle_per_frame = TAU / total_directions  # TAU = 2π, one full circle

	# Normalize rotation to 0 - TAU 
	var normalized_rotation = fmod(rotation + TAU, TAU)

	# Calculate which frame to use
	var frame = int(round(normalized_rotation / angle_per_frame)) % total_directions

	boat_sprite.play("default")
	boat_sprite.set_frame(frame)
	
# --- function that handles shooting the cannon ---
func fire_cannon(marker: Marker2D, is_left: bool):
	var cannonball = cannonball_scene.instantiate()
	cannonball.global_position = marker.global_position

	var angle = rotation
	if is_left:
		angle -= PI / 2  # Left cannon fires perpendicular to the left
	else:
		angle += PI / 2  # Right cannon fires perpendicular to the right

	cannonball.direction = Vector2.UP.rotated(angle).normalized()
	get_tree().current_scene.add_child(cannonball)
	
	# Plays cannon flash animation (this is a super janky way to do it but i cant be bothered to change it rn)
	if is_left:
		$LeftCannonFlash.play("flashleft")
		$LeftCannonFlash.visible = true
	else:
		$RightCannonFlash.play("flashright")
		$RightCannonFlash.visible = true
	
	
