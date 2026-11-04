extends CharacterBody3D

const JUMP_VELOCITY = 4.5

@onready var globals : global = get_node("/root/Global")
@onready var camera : Camera3D = $pivotX/pivotY/SpringArm3D/Camera3D
@onready var arm : SpringArm3D = $pivotX/pivotY/SpringArm3D
@onready var camPivotX : Node3D = $pivotX
@onready var camPivotY : Node3D = $pivotX/pivotY

@export var playerClass : int

var speedMultiplier : int = 1
var maxSpeed : float = 3.0
var acceleration : float = 5.0
var rotX : float
var rotY : float
var distanceToPlayer : int = 4


func _ready() -> void:
	camera.fov = globals.playerFov
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	#I got this camera movement script from the godot wiki
	#https://docs.godotengine.org/en/stable/tutorials/3d/using_transforms.html
	if event is InputEventMouseMotion:
		rotX -= event.screen_relative.x * globals.playerSens
		rotY -= event.screen_relative.y * globals.playerSens
		camPivotX.transform.basis = Basis()
		camPivotY.transform.basis = Basis()
		camPivotY.rotate_x(rotY)
		camPivotX.rotate_y(rotX)
		
		camPivotY.rotation.x = clampf(camPivotY.rotation.x, -(PI / 2), PI / 2)
		rotY = clampf(rotY, -(PI / 2), PI / 2)
		#print(camPivot.rotation_degrees.x)
	
	if Input.is_action_just_pressed("zoomIn"):
		var tween = get_tree().create_tween()
		distanceToPlayer -= 1
		tween.tween_property(arm, "spring_length", distanceToPlayer, 0.1)
		if distanceToPlayer < 4:
			distanceToPlayer = 4
	
	if Input.is_action_just_pressed("zoomOut"):
		var tween = get_tree().create_tween()
		distanceToPlayer += 1
		tween.tween_property(arm, "spring_length", distanceToPlayer, 0.1)
	if distanceToPlayer > 30:
		distanceToPlayer = 30


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	print(velocity)
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (camPivotX.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0
	if direction.x:
		velocity.x = move_toward(velocity.x , maxSpeed * direction.x, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x , 0, acceleration * delta)
	if direction.z:
		velocity.z = move_toward(velocity.z , maxSpeed * direction.z, acceleration * delta)
	else:
		velocity.z = move_toward(velocity.z , 0, acceleration * delta)
	
	if velocity.x > maxSpeed:
		velocity.x = maxSpeed
	elif velocity.x < -maxSpeed:
		velocity.x = -maxSpeed
	if velocity.z > maxSpeed:
		velocity.z = maxSpeed
	elif velocity.z < -maxSpeed:
		velocity.z = -maxSpeed

	move_and_slide()
