extends Node
class_name classes

@onready var abilityTimer := $"../Ability"

@export var player : player 

var hasDived := false
var isCharging := false

func _physics_process(delta: float) -> void:
	if player.is_on_floor():
		hasDived = false
	if Input.is_action_pressed("Ability") and !hasDived and !player.stop:
		match player.playerClass:
			1:
				if abilityTimer.is_stopped():
					player.maxSpeed = 15
					player.accelerationMod = 30
					player.currentAnimation = 5
					isCharging = true
					player.velocity.x = move_toward(player.velocity.x, player.maxSpeed * player.lastDir.x, delta * player.accelerationMod)
					player.velocity.z = move_toward(player.velocity.z, player.maxSpeed * player.lastDir.z, delta * player.accelerationMod)
					player.mesh.global_rotation.y = player.targetAngle
					player.mesh.global_rotation.y = lerp_angle(player.mesh.rotation.y, player.targetAngle, player.rotationSpeed * delta)
					
					#switch to tank controls when we activate the charging ability
					if Input.is_action_pressed("Left"):
						player.targetAngle += deg_to_rad(0.2)
						player.lastDir = player.lastDir.rotated(Vector3(0, 1, 0), deg_to_rad(0.2))
					if Input.is_action_pressed("Right"):
						player.targetAngle -= deg_to_rad(0.2)
						player.lastDir = player.lastDir.rotated(Vector3(0, 1, 0), deg_to_rad(0.2))
			2:
				player.velocity = player.lastDir * 10
				player.velocity.y += 2
				hasDived = true
				player.disableMovement = true
	else:
		match  player.playerClass:
			1:
				if Input.is_action_just_released("Ability") and isCharging:
					abilityTimer.start()
				player.maxSpeed = 3
				if player.velocity.x > 3 or player.velocity.x < -3:
					player.accelerationMod = 10
				if player.velocity.z > 3 or player.velocity.z < -3:
					player.accelerationMod = 10
