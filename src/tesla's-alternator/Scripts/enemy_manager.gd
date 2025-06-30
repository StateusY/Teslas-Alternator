extends CharacterBody2D

#region Variables

@onready var target : Node2D = get_node("../Player")

var state : String = "nav"  # "idle" "nav" "attack"

@export_group("Movement")
@export var is_movement_enabled = true
@export var speed = 50.0
@export_range(0,100,0.01, "or_greater") var attack_range : float = 50.0

@export_group("Attacking")
@export var attack_interval = 100.0

@export_group("Health and Loot")
@export var health : int
@export var drops : int
@export var loot_item : PackedScene

# junk variables
var navToggle = true
var attackToggle = true
var readyToAttack = false
var attackTimer = 0.0
var currentHealth
var isDeadManWalking = false
var modAlter = 1
var attackPosition : Vector2
var attackDirection : Vector2
#endregion

func _ready() -> void:
	if is_movement_enabled: $NavigationAgent2D.movement_speed = speed
	$AnimatedSprite2D.animation = "default"
	$AnimatedSprite2D.play()
	currentHealth = health

func _physics_process(delta: float) -> void:
	$AnimatedSprite2D.modulate = Color(modAlter,1,1,1)
	if modAlter > 1:
		modAlter -= 1
	
	if !isDeadManWalking:
		if state == "nav":
			$NavigationAgent2D.enabled = true
			
			attackTimer += 1
			if attackTimer >= attack_interval:
				attackTimer = 0
				readyToAttack = true
			
			if readyToAttack and attack_range >= position.distance_to(target.global_position):
				$NavigationAgent2D.enabled = false
				state = "attack"
				velocity = Vector2(0.0,0.0)
				$NavigationAgent2D.velocity = Vector2(0.0,0.0)
		
		if state == "attack":
			$AttackMove.attack(delta)
			if attackToggle:
				attackToggle = false
				readyToAttack = false
				attackPosition = target.position
				attackDirection = (attackPosition - position).normalized()
				$AnimatedSprite2D.animation = "attack"
				$AnimatedSprite2D.play()
		else:
			attackToggle = true
		if $AnimatedSprite2D.is_playing() == false:
			state = "nav"
			$AnimatedSprite2D.animation = "default"
			$AnimatedSprite2D.play()
	else:
		if $AnimatedSprite2D.is_playing() == false:
			queue_free()

func kill():
	currentHealth -= 1
	if currentHealth <= 0:
		isDeadManWalking = true
		$NavigationAgent2D.enabled = false
		velocity = Vector2(0.0,0.0)
		$NavigationAgent2D.velocity = Vector2(0.0,0.0)
		$AnimatedSprite2D.animation = "death"
		$AnimatedSprite2D.play()
		for i in range(drops):
			var loot = loot_item.instantiate()
			loot.z_index = 6
			get_tree().current_scene.call_deferred("add_child", loot)
			loot.position = self.global_position
	else:
		modAlter = 10
