extends Node3D

@onready var connectorEnd : Marker3D = $control/connectorNodeEnd
@onready var Collision := $control/Area3D
@onready var tileGifts := $control/tileGifts

@export var isOverlapping := false
@export var connectionPoints := 1
@export var connected := 0
@export var giftAmount : int


func _on_area_3d_area_entered(area: Area3D) -> void:
	isOverlapping = true
