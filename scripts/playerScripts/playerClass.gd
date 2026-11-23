extends Node
class_name classes

@onready var abilityTimer := $"../Ability"
@onready var abilityBar := $"../Control/AspectRatioContainer/ProgressBar"

@export var player : player 

var hasDived := false
var isCharging := false
var diverJumped := false
var setDiverVelocity

enum classType {
	CHARGER,
	DIVER
}


func _physics_process(delta: float) -> void:
	abilityBar.value = (abilityTimer.time_left / abilityTimer.wait_time) * 100
	
	if abilityBar.value == 0:
		abilityBar.visible = false
	else:
		abilityBar.visible = true

	if player.is_on_floor() and diverJumped:
		hasDived = false
		diverJumped = false

	#holy this is hard to work with
	if Input.is_action_pressed("Ability") and !player.stop:
		match player.playerClass:
			classType.CHARGER:
				if player.is_on_floor() and abilityTimer.is_stopped():
					player.maxSpeed = 15
					player.accelerationMod = 40
					player.setAnimation = player.state.CHARGE
					isCharging = true
					player.velocity.x = move_toward(player.velocity.x, player.maxSpeed * player.lastDir.x, delta * player.accelerationMod)
					player.velocity.z = move_toward(player.velocity.z, player.maxSpeed * player.lastDir.z, delta * player.accelerationMod)
					player.mesh.global_rotation.y = player.targetAngle
					player.mesh.global_rotation.y = lerp_angle(player.mesh.rotation.y, player.targetAngle, player.rotationSpeed * delta)
					
					#switch to tank controls when we activate the charging ability
					if Input.is_action_pressed("Left"):
						player.targetAngle += deg_to_rad(0.2)
						player.lastDir = player.lastDir.rotated(Vector3(0, 1, 0), deg_to_rad(0.1))
					if Input.is_action_pressed("Right"):
						player.targetAngle -= deg_to_rad(0.2)
						player.lastDir = player.lastDir.rotated(Vector3(0, 1, 0), deg_to_rad(-0.1))
					
					if Input.is_action_just_pressed("Jump"):
						abilityTimer.start()
				elif !player.is_on_floor() and !isCharging:
					player.velocity.y = -15
			
			classType.DIVER:
				if !hasDived and player.velocity.abs().x > 0.5 or !hasDived and player.velocity.abs().z > 0.5:
					player.speedMultiplier = 2.4
					setDiverVelocity = player.maxSpeed * player.speedMultiplier
					print(setDiverVelocity)
					player.velocity = player.direction * Vector3(setDiverVelocity, 0, setDiverVelocity)
					player.targetAngle = Vector3.FORWARD.signed_angle_to(player.velocity, Vector3.UP)
					player.velocity.y += 2
					player.accelerationMod = 20
					hasDived = true
					diverJumped = false
					player.setAnimation = player.state.DIVE
					player.mesh.global_rotation.y = player.targetAngle
					player.defaultCollision.disabled = true
					player.slideCollision.disabled = false
					
					await get_tree().physics_frame
					if player.velocity.x > 6:
						player.velocity.x = 6
					if player.velocity.x < -6:
						player.velocity.x = -6
					if player.velocity.z > 6:
						player.velocity.z = 6
					if player.velocity.z < -6:
						player.velocity.z = -6
	else:
		match  player.playerClass:
			classType.CHARGER:
				player.maxSpeed = 3
				if player.velocity.x > 3 or player.velocity.x < -3:
					player.accelerationMod = 10
					player.velocity.x = move_toward(player.velocity.x , 0, player.accelerationMod * delta)
				if player.velocity.z > 3 or player.velocity.z < -3:
					player.accelerationMod = 10
					player.velocity.z = move_toward(player.velocity.z , 0, player.accelerationMod * delta)
				if (player.velocity.x < 3 or player.velocity.x > -3) and (player.velocity.z < 3 or player.velocity.z > -3) and isCharging:
					isCharging = false
					abilityTimer.start()
			
			classType.DIVER:
				if diverJumped and player.is_on_floor():
					hasDived = false
					diverJumped = false
					player.setAnimation = player.state.JUMP
