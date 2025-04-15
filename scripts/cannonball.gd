extends Area2D

@export var speed: float = 400.0
@export var arc_scale_min: float = 0.5
@export var arc_scale_max: float = 1.5
@export var lifetime: float = .75
@export var splash_scene: PackedScene

var direction: Vector2 = Vector2.ZERO
var time_elapsed: float = 0.0

func _ready():
	$DespawnTimer.start()
	$DespawnTimer.wait_time = lifetime

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
		# this makes the cannonball look like its arcing
	time_elapsed += delta
	var t = time_elapsed / lifetime
	var arc_factor = sin(t * PI)  # rises to 1 at halfway, then back to 0

	var current_scale = lerp(arc_scale_min, arc_scale_max, arc_factor)
	scale = Vector2.ONE * current_scale




func _on_despawn_timer_timeout() -> void:
	if splash_scene:
		var splash = splash_scene.instantiate()
		splash.global_position = global_position
		get_tree().current_scene.add_child(splash)
	queue_free()
