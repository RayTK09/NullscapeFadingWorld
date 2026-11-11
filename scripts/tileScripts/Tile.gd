extends Node3D

@onready var connectors := $control/connectors.get_children()
@onready var Collision := $control/Area3D
@onready var checkCollision := $control/Area3D

@export var giftAmount : int = 0

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	#this is jank, but it works
	#so it WAS frame dependant. but physics process has fixed it
	await get_tree().physics_frame
	await get_tree().physics_frame
	var getCollisions = checkCollision.get_overlapping_bodies()
	if len(getCollisions) > 1:
		print("tile removed")
		queue_free()
