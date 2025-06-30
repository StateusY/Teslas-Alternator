extends CharacterBody2D

# general
@onready var effectMiniMan = get_node("EffectsLocalManager")
@export var soundEffectPlayer : PackedScene
var loot = 0

# movement varibles
var xDir = 0
var yDir = 0
var speed = 10
var maxSpeed = 100
var velCutOff = 0.001
var friction = .75

var isDashing = false
var canDash = true
var dashPower = 100.0
var dashMult = 1.0  # working dash trigger - do not edit - sources from dashPower
var dashTimer = 0  # counter
var dashTime = 2  # duration of dash
var dashWait = 30  # cooldown of dash
  # change dash notif anim in SpriteFrames editor
@export var dashSoundEffect : AudioStream
@export var dashTrailEffect : PackedScene
var trail  # dash trail framework

# shooting varibles
var shootTimer = 0  # counter
var shootTime = 15
var canShoot = true
@export var Bullet : PackedScene
@onready var FirePoint = get_node("FirePoint")

#squash
@onready var SpriteRenderer = get_node("Sprite2D")
var spriteSquash = false
var squashRestoreFactor = 0.02  # added to scale every tick to restore the scale to original size

func _physics_process(delta: float) -> void:
	# movement
	movement_and_rotation()
	
	# shooting
	shooting()
	
	# squash
	squash()
	
func movement_and_rotation():
	
	# inputs
	if Input.is_key_pressed(KEY_W):
		yDir = -1
	elif Input.is_key_pressed(KEY_S):
		yDir = 1
	else:
		yDir = 0
	if Input.is_key_pressed(KEY_D):
		xDir = 1
	elif Input.is_key_pressed(KEY_A):
		xDir = -1
	else:
		xDir = 0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and canDash and (xDir != 0 or yDir != 0):
		isDashing = true
		dashMult = dashPower
		canDash = false
		
		var audio = soundEffectPlayer.instantiate()
		get_tree().current_scene.call_deferred("add_child", audio)
		audio.stream = dashSoundEffect
		audio.volume_db = -12
	
	# dash timer
	if !canDash:
		dashTimer += 1
		if dashTimer >= dashTime and isDashing:
			isDashing = false
		if dashTimer >= dashWait:
			canDash = true
			dashTimer = 0
			effectMiniMan.set_animation("DashNotif")
			effectMiniMan.play()
	
	# dash notif counter rotation
	effectMiniMan.global_rotation = 0
	
	# friction
	if xDir != 0:
		velocity.x += xDir * speed * dashMult
	else:
		velocity.x *= friction
	if yDir != 0:
		velocity.y += yDir * speed * dashMult
	else:
		velocity.y *= friction
	
	# quick turn speed
	if xDir * -1 == sign(velocity.x): velocity.x *= -.1
	if yDir * -1 == sign(velocity.y): velocity.y *= -.1
	
	# velocity cutoff
	if abs(velocity.x) < velCutOff: velocity.x = 0
	if abs(velocity.y) < velCutOff: velocity.y = 0
	
	# max speed
	if abs(velocity.x) > maxSpeed and !isDashing: velocity.x = maxSpeed * sign(velocity.x)
	if abs(velocity.y) > maxSpeed and !isDashing: velocity.y = maxSpeed * sign(velocity.y)
	move_and_slide()
	
	# reset dash boost
	dashMult = 1.0
	
	# rotate towards mouse
	rotation = (get_global_mouse_position() - global_position).angle() - PI/2

func shooting():
	# inputs
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and canShoot:
		shoot()
		shootTimer = 0
		canShoot = false
	
	# timers
	shootTimer += 1
	if shootTimer > shootTime:
		shootTimer = 0
		canShoot = true
	
func shoot():
	SpriteRenderer.scale.y = 0.75
	spriteSquash = true
	var b = Bullet.instantiate()
	get_tree().current_scene.add_child(b)
	b.position = FirePoint.global_position
	b.xDir = -cos(rotation + PI / 2)
	b.yDir = -sin(rotation + PI / 2)

func squash():
	if spriteSquash == true:
		SpriteRenderer.scale.y += squashRestoreFactor
	if SpriteRenderer.scale.y >= 1:
		SpriteRenderer.scale.y = 1
		spriteSquash = false

func kill():
	pass
