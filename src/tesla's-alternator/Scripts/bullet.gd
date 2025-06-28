extends Area2D

var speed = 150
var xDir = 0
var yDir = 0
@export var Effect : PackedScene
@onready var effMan = get_node("EffectsManager")

func _on_body_entered(body):
	if body.has_method("kill"): body.kill()
	if body.is_in_group("bullet_kill"):
		onDeath()

func _physics_process(delta: float) -> void:
	position -= transform.x * speed * delta * xDir
	position -= transform.y * speed * delta * yDir

func onDeath():
	effMan.onDeath()
	queue_free()
