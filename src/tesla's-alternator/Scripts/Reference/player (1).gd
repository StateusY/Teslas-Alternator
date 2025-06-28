extends Node2D

@export var Bullet : PackedScene
@export var MuzzleSprite : Node
@export var MuzzlePoint : Node
@onready var globals = get_node("/root/Main Scene/Globals")
@onready var cursor = get_node("/root/Main Scene/UI Elements/CursorFollower")
@onready var deathMessage = get_node("/root/Main Scene/UI Elements/CanvasLayer/DeathText")
@export var missile : PackedScene
@export var shield : PackedScene

#isController
var mousePos
var shootInterval = 15
var shootClock = 0

#keyboard
var speed = 2.0
var xCtrl = 0
var yCtrl = 0

var xVel = 0
var yVel = 0
var maxSpeed = 15
var xMoment = 0
var yMoment = 0


@export var currentAbility = "" #shield, missile
var abilityToggled = false

var isSheilding: bool = false
var sheildingSpeed = 5
var sheildingClock = 0
var shieldActive: bool = false
var shld
@onready var shieldBar = get_node("/root/Main Scene/UI Elements/ShieldBar")

var missileClock = 0
var missileInterval = 50
var isMissileReady = false
@onready var missileDisplay = get_node("/root/Main Scene/UI Elements/CanvasLayer/MissileDisplay")

var yOffset = 0

func hit():
	if isSheilding == false:
		deathMessage.show()
		get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#shoot effect
	if yOffset > 0 and isSheilding == false:
		yOffset -= 1
	shootClock += 1
	if shootClock >= shootInterval:
		shoot()
		shootClock = 0
		yOffset = 5
		
		
	if globals.isController == true:
		#follow mouse
		mousePos = get_viewport().get_mouse_position()
		position.x = mousePos.x - (get_window().size.x/2)
		position.y = mousePos.y + yOffset - (get_window().size.y/2)
	else:
		#wasd controller
		if Input.is_key_pressed(KEY_W):
			yCtrl = -1
		if Input.is_key_pressed(KEY_S):
			yCtrl = 1
		if not Input.is_key_pressed(KEY_W) and not Input.is_key_pressed(KEY_S):
			yCtrl = 0
		if Input.is_key_pressed(KEY_A):
			xCtrl = -1
		if Input.is_key_pressed(KEY_D):
			xCtrl = 1
		if not Input.is_key_pressed(KEY_A) and not Input.is_key_pressed(KEY_D):
			xCtrl = 0
		
		if Input.is_key_pressed(KEY_E) and abilityToggled == false:
			abilityToggled = true
			if currentAbility == "shield":
				currentAbility = "missile"
			else:
				currentAbility = "shield"
		elif not Input.is_key_pressed(KEY_E):
			abilityToggled = false
		
		
		#move stuff
		xMoment += xCtrl * speed /4
		yMoment += yCtrl * speed /4
		xMoment *= 0.75
		yMoment *= 0.75
		xVel += xMoment
		yVel += yMoment
		xVel *= 0.88
		yVel *= 0.88
		if xVel > maxSpeed: xVel = maxSpeed
		if yVel > maxSpeed: yVel = maxSpeed
		if xVel < -maxSpeed: xVel = -maxSpeed
		if yVel < -maxSpeed: yVel = -maxSpeed
		position.x += xVel
		position.y += yVel
		
		
		if currentAbility == "shield":
			shieldBar.show()
			if Input.is_key_pressed(KEY_SHIFT) and globals.sheildPercent > 0:
				isSheilding = true
			else:
				isSheilding = false
		else:
			shieldBar.hide()
			isSheilding = false
		
		if currentAbility == "missile":
			missileDisplay.show()
			if globals.missilePercent == 6: isMissileReady = true
			if Input.is_key_pressed(KEY_SHIFT) and isMissileReady == true:
				isMissileReady = false
				globals.missilePercent = 0
				var b = missile.instantiate()
				owner.add_child(b)
				b.position = MuzzlePoint.global_position
				b.rotation = MuzzlePoint.global_rotation + PI/2
		else:
			missileDisplay.hide()
		
		missileClock += 1
		if missileClock >= missileInterval:
			missileClock = 0
			globals.missilePercent += 1
			
		
		var d = cursor.position.angle_to_point(position)
		d -= PI/2
		rotation = d
		
	MuzzleSprite.position.y = yOffset - 15
	
	
	#sheilding bit
	sheildingClock += 1
	if isSheilding == true:
		if shieldActive == false:
			shld = shield.instantiate()
			self.add_child(shld)
			shieldActive = true
		if sheildingClock >= sheildingSpeed:
			sheildingClock = 0
			globals.sheildPercent -= 1
		shld.scale = Vector2(pow(globals.sheildPercent,1/6),pow(globals.sheildPercent,1/6))
	elif shieldActive == true and isSheilding == false:
		shld.queue_free()
		shieldActive = false
	if globals.sheildPercent <= 0: isSheilding == false


func shoot():
	if isSheilding == false:
		var b = Bullet.instantiate()
		owner.add_child(b)
		b.position = MuzzlePoint.global_position
		b.rotation = MuzzlePoint.global_rotation

func _on_area_entered(body):
	if body.is_in_group("enemy"):
		body.kill()
		hit()
