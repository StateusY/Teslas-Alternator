extends Area2D
@onready var globals = get_node("/root/Main Scene/Globals")
var minimap_icon = "enemy"

var spinSpeed = -0.1
var VELOCITY = 400.0
@export var absRot = 0

@export var Bullet : PackedScene
@onready var player = get_node("/root/Main Scene/player")
@onready var minimap = get_node("/root/Main Scene/UI Elements/CanvasLayer/MiniMap")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	VELOCITY*=globals.difficulty
	absRot = rotation
	minimap.add_icon(self)

func kill():
	globals.sheildPercent += 1
	var b = Bullet.instantiate()
	get_tree().current_scene.add_child(b)
	b.position = self.global_position
	b.rotation = self.global_rotation
	var v = Vector2(position.x-player.position.x,position.y-player.position.y)
	v = v.normalized()
	b.Xdir = v.x
	b.Ydir = v.y
	
	var a = Bullet.instantiate()
	get_tree().current_scene.add_child(a)
	a.position = self.global_position
	a.rotation = self.global_rotation
	var y = Vector2(position.x-player.position.x,position.y-player.position.y)
	y = y.normalized()
	a.Xdir = y.x
	a.Ydir = y.y+2
	
	var c = Bullet.instantiate()
	get_tree().current_scene.add_child(c)
	c.position = self.global_position
	c.rotation = self.global_rotation
	var w = Vector2(position.x-player.position.x,position.y-player.position.y)
	w = w.normalized()
	c.Xdir = w.x-1
	c.Ydir = w.y+1
	
	var d = Bullet.instantiate()
	get_tree().current_scene.add_child(d)
	d.position = self.global_position
	d.rotation = self.global_rotation
	var x = Vector2(position.x-player.position.x,position.y-player.position.y)
	x = x.normalized()
	d.Xdir = x.x+1
	d.Ydir = x.y+1
	
	#for i in range(globals.targetedEnemies.size()-1):
		#if globals.targetedEnemies[i] == self:
			#globals.targetedEnemies.remove_at(i)
	queue_free()
	minimap.remove_obj(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var d = player.position.angle_to_point(position) 
	rotation += spinSpeed
	absRot = Util.rotate_toward(absRot, d, 5*delta)
	position += Vector2.LEFT.rotated(absRot) * VELOCITY * delta
