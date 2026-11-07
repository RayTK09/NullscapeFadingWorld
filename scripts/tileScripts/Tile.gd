extends Node3D

@onready var connectorEnd : Marker3D = $connectorNodeEnd
@onready var Collision := $control/Area3D

@export var isOverlapping := false
@export var connectionPoints := 1
@export var connected := 0


func _on_area_3d_area_entered(area: Area3D) -> void:
	isOverlapping = true
