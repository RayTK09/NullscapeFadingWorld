#cant believe I lost 3 hours of work because hackatime detected 2 projects as the same like wtf
#NEVERMIND HOLY CRAP
class_name player
extends CharacterBody3D


const DEFAULTSPEED := 3.0

@onready var globals : global = get_node("/root/Global")
@onready var camera : Camera3D = $pivotX/pivotY/SpringArm3D/Camera3D
@onready var arm : SpringArm3D = $pivotX/pivotY/SpringArm3D
@onready var camPivotX : Node3D = $pivotX
@onready var camPivotY : Node3D = $pivotX/pivotY
@onready var mesh := $charMesh
@onready var defaultCollision := $CollisionShape3D
@onready var slideCollision := $slideCollision
@onready var control := $deathControl
@onready var deathTimer := $deathTimer

@export var rotationSpeed : float = 4
@export var jumps : int = 1
@export var classes : classes
@export var playerClass : classes.classType = classes.classType.CHARGER

var jumpVelocity = 4.5
var airAcceleration = 1.5
var speedMultiplier : int = 1
var maxSpeed : float = 3.0
var acceleration : float = 8.0
var rotX : float
var rotY : float
var distanceToPlayer : int = 4
var lastDir := Vector3.FORWARD
var stop := false
var isDead := false
var accelerationMod : int = 0
var targetAngle
var setAnimation
var direction
var setVelocityLatch := false
var lastMousePos : Vector2
var latch := false

#I love enums
enum state {
	IDLE,
	RUN,
	JUMP,
	FALL,
	CHARGE,
	DIVE
}


func _ready() -> void:
	camera.fov = globals.playerFov
	playerClass = globals.chooseClass


func _input(event: InputEvent) -> void:
	#I got this camera movement script from the godot wiki
	#https://docs.godotengine.org/en/stable/tutorials/3d/using_transforms.html
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotX -= event.screen_relative.x * globals.playerSens
		rotY -= event.screen_relative.y * globals.playerSens
		camPivotX.transform.basis = Basis()
		camPivotY.transform.basis = Basis()
		camPivotY.rotate_x(rotY)
		camPivotX.rotate_y(rotX)
		
		camPivotY.rotation.x = clampf(camPivotY.rotation.x, -(PI / 2), PI / 2)
		rotY = clampf(rotY, -(PI / 2), PI / 2)
		#print(camPivot.rotation_degrees.x)
		
	if Input.is_action_just_pressed("unlock Mouse") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_pressed("unlock Mouse") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("zoomIn"):
		var tween = get_tree().create_tween()
		distanceToPlayer -= 1
		tween.tween_property(arm, "spring_length", distanceToPlayer, 0.2)
		if distanceToPlayer < 3:
			distanceToPlayer = 3
	
	if Input.is_action_just_pressed("zoomOut"):
		var tween = get_tree().create_tween()
		distanceToPlayer += 1
		tween.tween_property(arm, "spring_length", distanceToPlayer, 0.2)
		if distanceToPlayer > 30:
			distanceToPlayer = 30


func _physics_process(delta: float) -> void:
	if !stop:
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		if velocity.y > 0 and setAnimation != state.DIVE:
			setAnimation = state.JUMP

		if velocity.y <= 0 and setAnimation != state.DIVE:
			setAnimation = state.FALL

		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = jumpVelocity
			if classes.isCharging and classes.abilityTimer.is_stopped():
				classes.abilityTimer.start()
				classes.isCharging = false
				maxSpeed = 3.0
		
		#diver jump
		if classes.hasDived and !classes.diverJumped and Input.is_action_just_pressed("Jump"):
			velocity.y = jumpVelocity
			classes.diverJumped = true
			defaultCollision.disabled = false
			slideCollision.disabled = true
			setAnimation = state.JUMP
			if !direction:
				velocity = Vector3(0, velocity.y, 0)
		
		if setAnimation == state.DIVE:
			floor_max_angle = deg_to_rad(40)
		else:
			floor_max_angle = deg_to_rad(55)
		
		#why does movement have to be so difficult
		#special thanks to GDQuest for the rotation for the mesh
		#https://youtu.be/JlgZtOFMdfc
		var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
		direction = (camPivotX.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		direction.y = 0
		
		if direction.length() > 0.2 and !classes.isCharging and !classes.hasDived:
			lastDir = direction
		
		if !classes.isCharging:
			targetAngle = Vector3.FORWARD.signed_angle_to(lastDir, Vector3.UP)
		#print(direction.dot(Vector3(0, 0, targetAngle)))
		if velocity.x == 0 and velocity.z == 0 and direction and setAnimation != state.DIVE and !velocity:
			#turn to face the direction of where local z is and save the position so it dont rotate back to default
			mesh.global_rotation.y = targetAngle
		if !isDead:
			if direction.x and is_on_floor() and setAnimation != state.DIVE and !classes.isCharging:
				velocity.x = move_toward(velocity.x , maxSpeed * direction.x, (acceleration + accelerationMod) * delta)
				setAnimation = state.RUN
				mesh.global_rotation.y = lerp_angle(mesh.rotation.y, targetAngle, rotationSpeed * delta)
			elif is_on_floor() and !classes.isCharging:
				velocity.x = move_toward(velocity.x , 0, (acceleration + accelerationMod) * delta)
				if !classes.hasDived:
					setAnimation = state.IDLE
				
			if direction.z and is_on_floor() and setAnimation != state.DIVE and !classes.isCharging:
				velocity.z = move_toward(velocity.z , maxSpeed * direction.z,(acceleration + accelerationMod) * delta)
				setAnimation = state.RUN
				mesh.global_rotation.y = lerp_angle(mesh.rotation.y, targetAngle, rotationSpeed * delta)
			elif is_on_floor() and !classes.isCharging:
				velocity.z = move_toward(velocity.z , 0, (acceleration + accelerationMod) * delta)
				if !classes.hasDived:
					setAnimation = state.IDLE
			
			#print(velocity)
			#print(velocity.rotated(Vector3.UP, targetAngle))
			
			if !is_on_floor() and !setVelocityLatch and !classes.isCharging:
				maxSpeed = _setVelocityLimit(velocity.x, velocity.z)
				airAcceleration = _setAcceleration(velocity.x, velocity.z)
				setVelocityLatch = true
			elif is_on_floor():
				maxSpeed = DEFAULTSPEED
				setVelocityLatch = false
			
			#print(maxSpeed)
			#print(airAcceleration)
			
			#AIR CONTROL
			#disable air control during dive
			if direction.x and !is_on_floor() and setAnimation != state.DIVE:
				velocity.x = move_toward(velocity.x , maxSpeed * direction.x, airAcceleration * delta)
				#mesh.global_rotation.y = lerp_angle(mesh.rotation.y, targetAngle, rotationSpeed * delta)
			elif !is_on_floor() and setAnimation != state.DIVE:
				velocity.x = move_toward(velocity.x , 0, (acceleration + accelerationMod) * delta)
			
			if direction.z and !is_on_floor() and setAnimation != state.DIVE:
				velocity.z = move_toward(velocity.z , maxSpeed * direction.z, airAcceleration * delta)
				#mesh.global_rotation.y = lerp_angle(mesh.rotation.y, targetAngle, rotationSpeed * delta)
			elif !is_on_floor() and setAnimation != state.DIVE:
				velocity.z = move_toward(velocity.z , 0, (acceleration + accelerationMod) * delta)

			if velocity.x <= 3 and velocity.x >= -3:
				accelerationMod = 0
			if velocity.z <= 3 and velocity.z >= -3:
				accelerationMod = 0

		move_and_slide()


#set our last velocity is to the max velocity while in air
func _setVelocityLimit(currentVelocityX, currentVelocityZ) -> float:
	var newMaxSpeed = sqrt((currentVelocityX * currentVelocityX) + (currentVelocityZ * currentVelocityZ))
	return newMaxSpeed
	
func _setAcceleration(currentVelocityX, currentVelocityZ) -> float:
	var newAcceleration = sqrt((currentVelocityX * currentVelocityX) + (currentVelocityZ * currentVelocityZ))
	return newAcceleration / 2


func _on_death_timer_timeout() -> void:
	control.visible = true


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
