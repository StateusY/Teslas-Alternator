extends Node2D

const speed = 200

func attack(delta : float):
	if owner.position != owner.attackPosition:
		owner.velocity = owner.attackDirection * speed
		owner.move_and_slide()
	else:
		owner.velocity = Vector2.ZERO
