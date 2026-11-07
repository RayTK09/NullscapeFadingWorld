extends Node3D

@onready var tileStart1 : Marker3D = $spawnTile/startTile
@onready var tileStart2 : Marker3D = $spawnTile/startTile2
@onready var tileStart3 : Marker3D = $spawnTile/startTile3
@onready var tileStart4 : Marker3D = $spawnTile/startTile4
@onready var straightTile = preload('res://scenes/Tiles/straightTile.tscn')
@onready var activeTiles := $activeTiles

var tileLimit : int = 7
var tileTypes : Array
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var spawners = [tileStart1, tileStart2, tileStart3, tileStart4]
	for i in spawners.size():
		activeTiles.add_child(straightTile.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		var tiles = activeTiles.get_children()
		print(activeTiles.get_children())
		tiles[i].position = spawners[i].global_position
		tiles[i].rotation = spawners[i].rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#for i in tileLimit:
		#placeTiles()
	pass

func placeTiles():
	for i in tileLimit * currentLevel:
		activeTiles.add_child(straightTile.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		var tiles = activeTiles.get_children()
		print(activeTiles.get_children())
		tiles[i].position = spawners[i].global_position
		tiles[i].rotation = spawners[i].rotation
	
