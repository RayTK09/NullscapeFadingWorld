extends Node3D

@onready var globals : global = get_node("/root/Global")


func _on_area_3d_body_entered(body: Node3D) -> void:
	queue_free()
	print("gift collected!")
	globals.collectedGifts += 1
