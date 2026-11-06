class_name straightTile
extends Node3D

@onready var connectorNode1 : Marker3D = $connectorNode
@onready var connectorNode2 : Marker3D = $connectorNode2
@onready var Collision := $control/Area3D


func checkValid() -> bool:
	if Collision.has_overlapping_areas():
		return false
	return true
