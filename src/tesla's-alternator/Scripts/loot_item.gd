extends Area2D

var target = null
var vaccuumSpeed = 10
var velocity = Vector2(0.0,0.0)
var slide_distance : float
var slide_rotation : float
@export var slide_speed = 50.0
@export var max_slide_distance = 20.0
@export var audio_player : PackedScene
@export var pickup_sound : AudioStream

var _direction: Vector2
var _start_position: Vector2
var _distance_moved: float = 0.0
var _sliding: bool = true

func _ready() -> void:
	slide_rotation = randf_range(0, PI * 2)
	slide_distance = randf_range(7,max_slide_distance)
	_direction = Vector2.RIGHT.rotated(slide_rotation) # convert rotation to direction vector
	_start_position = global_position

func _physics_process(delta: float) -> void:
	if target != null:
		velocity = global_position.direction_to(target.global_position) * vaccuumSpeed
	else:
		if not _sliding:
			return
			
		var move_step = _direction * slide_speed * delta
		global_position += move_step
		_distance_moved += move_step.length()
		
		if _distance_moved >= slide_distance:
			_sliding = false
			# Optionally snap to exact final position
			global_position = _start_position + _direction * slide_distance
		
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.loot += 1
		var audio = audio_player.instantiate()
		get_tree().current_scene.call_deferred("add_child", audio)
		audio.stream = pickup_sound
		queue_free()

func _on_vaccuum_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
