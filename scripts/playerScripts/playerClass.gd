extends Node
class_name classes

@export var player : player 

var hasDived := false


func _process(delta: float) -> void:
	if player.is_on_floor():
		hasDived = false
	if Input.is_action_pressed("Ability") and !hasDived:
		match player.playerClass:
			1:
				player.maxSpeed = 10
				player.accelerationMod = 20
			2:
				player.velocity = player.lastDir * 10
				player.velocity.y += 2
				hasDived = true
				player.disableMovement = true
	else:
		player.maxSpeed = 3
