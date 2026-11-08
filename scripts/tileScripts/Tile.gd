extends Node3D

@onready var connectorEnd : Marker3D = $control/connectorNodeEnd
@onready var Collision := $control/Area3D
@onready var tileGifts := $control/tileGifts
@onready var checkCollision := $control/Area3D

@export var isOverlapping := false
@export var connectionPoints := 1
@export var connected := 0
@export var giftAmount : int
