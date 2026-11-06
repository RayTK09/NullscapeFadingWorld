extends Node3D

@onready var tileStart1 : Marker3D = $spawnTile/startTile
@onready var tileStart2 : Marker3D = $spawnTile/startTile2
@onready var tileStart3 : Marker3D = $spawnTile/startTile3
@onready var tileStart4 : Marker3D = $spawnTile/startTile4
@onready var straightTile = "res://scenes/Tiles/straightTile.tscn"

@export var currentLevel : int = 1

var tileLimit : int = 7


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in tileLimit:
		placeTiles()

func placeTiles():
	var tiles = [straightTile]
	straightTile.check
	
