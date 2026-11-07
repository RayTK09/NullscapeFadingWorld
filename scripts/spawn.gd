extends Node3D

@onready var tileStart1 : Marker3D = $spawnTile/startTile
@onready var tileStart2 : Marker3D = $spawnTile/startTile2
@onready var tileStart3 : Marker3D = $spawnTile/startTile3
@onready var tileStart4 : Marker3D = $spawnTile/startTile4
@onready var straightTile = preload('res://scenes/Tiles/straightTile.tscn')
@onready var cornerTileRight = preload("res://scenes/Tiles/corner_tile_right.tscn")
@onready var cornerTileLeft = preload("res://scenes/Tiles/corner_tile_left.tscn")
@onready var activeTiles := $activeTiles
@onready var globals : global = get_node("/root/Global")

var tileLimit : int = 5
var tileTypes : Array
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#AHHHHHHHH THIS TOOK WAY TOO LONG TO FIGURE OUT
	var spawners = [tileStart1, tileStart2, tileStart3, tileStart4]
	for i in spawners.size():
		activeTiles.add_child(straightTile.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		var tiles = activeTiles.get_children()
		tiles[i].position = spawners[i].global_position
		tiles[i].rotation = spawners[i].rotation
	for i in tileLimit:
		placeTiles()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func placeTiles():
	var tileList = [straightTile, cornerTileLeft, cornerTileRight]
	var tiles : Array
	tiles = activeTiles.get_children()
	var chooseTile = rng.randi_range(0, tiles.size() - 1)
	var connectingTile = tiles[chooseTile]
	#check to see if the tile that we are connecting to is already connected to a tile
	if connectingTile.connected == connectingTile.connectionPoints:
		return
	#if it passes, create the tile
	# and choose a tile type to use
	var chooseTileType = rng.randi_range(0, 100)
	if chooseTileType <= 75:
		activeTiles.add_child(straightTile.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
	elif chooseTileType > 75 and chooseTileType <= 85:
		activeTiles.add_child(cornerTileLeft.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
	elif chooseTileType > 85:
		activeTiles.add_child(cornerTileRight.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
	tiles = activeTiles.get_children()
	var newTile = tiles.get(tiles.size() - 1)
	connectingTile.connected += 1
	print(newTile)
	print(tiles.size() - 1)
	newTile.position = connectingTile.connectorEnd.global_position
	newTile.rotation = connectingTile.connectorEnd.global_rotation
