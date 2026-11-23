extends Node3D

@onready var globals : global = get_node("/root/Global")
@onready var mesh := $control/blockbench_export
@onready var getCollisions := $control/Area3D

@export var giftType : String = "gift"

func _process(delta: float) -> void:
	mesh.rotate_object_local(Vector3(1, 0, 0), lerp(rotation.x, randf(), 0.05))
	mesh.rotate_object_local(Vector3(0, 1, 0), lerp(rotation.y, randf(), 0.05))
	mesh.rotate_object_local(Vector3(0, 0, 1), lerp(rotation.z, randf(), 0.05))
	if getCollisions.get_overlapping_bodies().size() >= 1:
		if giftType == "gift":
			print("gift collected!")
			globals.collectedGifts += 1
			queue_free()
		elif is_visible_in_tree():
			print("golden gift collected!")
			globals.goldenGiftsCollected += 1
			queue_free()
