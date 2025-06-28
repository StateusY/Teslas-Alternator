extends Sprite2D

var color : Color
var colorSVal = 0

#@export_group("Base Modifiers")
#@export var sizeMultiplier = 1.0

@export_group("Effects")
@export var fade : bool = false
@export var rotate : bool = true
@export var modRate = 0.25

@export_group("Color")
@export var colorHVal = 0.0
@export var colorVVal = 0.0

@export_group("Time")
@export var lockTime : bool = false
@export var timeLimit : float = 50

var rotateRate
var rotateDir
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if rotate:
		rotateRate = randf_range(0.05,0.1)
		rotateDir = (randi_range(0,1)*2)-1
	if not lockTime:
		timeLimit = randf_range(7.0,17.0)
	if not fade:
		scale = Vector2(0,0)
	#scale *= sizeMultiplier


func _physics_process(delta: float) -> void:
	if fade:
		modulate.a = 1 - timer / timeLimit
		if modulate.a == 0:
			queue_free()
	else:
		color = Color.from_hsv(colorHVal,colorSVal,colorVVal,1)
		colorSVal += 0.05
		modulate = color
		scale += Vector2(modRate,modRate)
		if timer >= timeLimit:
			queue_free()
	if rotate: rotation += rotateRate * rotateDir
	timer+=1
