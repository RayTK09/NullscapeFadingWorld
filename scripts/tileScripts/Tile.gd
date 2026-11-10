extends Node3D

@onready var connectorEnd : Marker3D = $control/connectorNodeEnd
@onready var Collision := $control/Area3D
@onready var tileGifts := $control/tileGifts
@onready var checkCollision := $control/Area3D

@export var connectionPoints := 1
@export var connected := 0
@export var giftAmount : int

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var getCollisions = checkCollision.get_overlapping_bodies()
	if len(getCollisions) > 1:
		print("tile removed")
		queue_free()
