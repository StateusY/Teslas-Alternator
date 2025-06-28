extends Node2D

@export_group("Visual")
@export var shootEffect : PackedScene
@export var hitEffect : PackedScene
@export var trailEffect : PackedScene
@export var trailInterval : float = 50
var trailTimer = 0.0
var shootEffectTriggered = false

@export_group("Audio - Needs Audio Player")
@export var shootSound : AudioStream
@export var hitSound : AudioStream
@export var audioPlayer : PackedScene

func _ready() -> void:
	pass

func onDeath():
	if hitEffect:
		var eff = hitEffect.instantiate()
		eff.z_index = 15
		get_tree().current_scene.call_deferred("add_child", eff)
		eff.position = self.global_position
	if hitSound:
		var audio = audioPlayer.instantiate()
		get_tree().current_scene.call_deferred("add_child", audio)
		audio.stream = hitSound

func _physics_process(delta: float) -> void:
	if shootEffectTriggered == false:
		if shootEffect:
			var eff = shootEffect.instantiate()
			eff.z_index = 15
			get_tree().current_scene.call_deferred("add_child", eff)
			eff.position = self.global_position
			shootEffectTriggered = true
		if shootSound:
			var audio = audioPlayer.instantiate()
			get_tree().current_scene.call_deferred("add_child", audio)
			audio.stream = shootSound
		
	if trailEffect:
		trailTimer+=1
		if trailTimer >= trailInterval:
			trailTimer = 0
			var eff = trailEffect.instantiate()
			get_tree().current_scene.call_deferred("add_child", eff)
			eff.position = self.global_position
