extends CharacterBody3D

const JUMP_VELOCITY = 4.5

@onready var globals : global = get_node("/root/Global")
@onready var camera : Camera3D = $SpringArm3D/Camera3D
@onready var arm : SpringArm3D = $SpringArm3D

@export var playerClass : int

var speedMultiplier : int = 1
var maxSpeed : float = 5.0
var rotX : float
var rotY : float


func _ready() -> void:
	camera.fov = globals.playerFov


func _input(event: InputEvent) -> void:
	#I got this camera movement script from the godot wiki
	#https://docs.godotengine.org/en/stable/tutorials/3d/using_transforms.html
	if event is InputEventMouseMotion:
		rotX -= event.screen_relative.x * globals.playerSens
		rotY -= event.screen_relative.y * globals.playerSens
		arm.transform.basis = Basis()
		arm.rotate_x(rotY)
		arm.rotate_y(rotX)
		
		if arm.rotation == Vector3(deg_to_rad(-90), 0, 0):
			rotate_x(deg_to_rad(90))



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * (delta * 1)
		velocity.z = direction.z * (delta * 1)
	else:
		velocity.x = move_toward(velocity.x, 0, (delta * 4))
		velocity.z = move_toward(velocity.z, 0, (delta * 4))
	
	if (velocity.x > maxSpeed):
		velocity.x = maxSpeed
	if (velocity.z > maxSpeed):
		velocity.z = maxSpeed

	move_and_slide()
