extends Node3D

@onready var area := $Area3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	body.velocity.y = 10
