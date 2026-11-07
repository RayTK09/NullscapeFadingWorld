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
@onready var beacon := $spawnTile/beacon

@export var player : player

var tileLimit : int = 0
var tileTypes : Array
var rng = RandomNumberGenerator.new()
var maxGifts : int = 0
var levelLoaded := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#AHHHHHHHH THIS TOOK WAY TOO LONG TO FIGURE OUT
	var spawners = [tileStart1, tileStart2, tileStart3, tileStart4]
	for i in spawners.size():
		activeTiles.add_child(straightTile.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		var tiles = activeTiles.get_children()
		tiles[i].position = spawners[i].global_position
		tiles[i].rotation = spawners[i].rotation
	maxGifts += 16
	
	#spawn tiles
	for i in tileLimit:
		placeTiles()
	
	beacon.monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	await levelLoaded
	if globals.collectedGifts == maxGifts:
		beacon.visible = true
		beacon.monitoring = true

func placeTiles():
	var tileList = [straightTile, cornerTileLeft, cornerTileRight]
	var tiles : Array
	tiles = activeTiles.get_children()
	var chooseTile = rng.randi_range(0, tiles.size() - 1)
	var connectingTile = tiles[chooseTile]
	#check to see if the tile that we are connecting to is already connected to a tile
	if connectingTile.connected == connectingTile.connectionPoints:
		placeTiles()
		return
	#if it passes, create the tile
	# and choose a tile type to use
	var chooseTileType = rng.randi_range(0, 100)
	if chooseTileType <= 75:
		activeTiles.add_child(straightTile.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		maxGifts += 4 
	elif chooseTileType > 75 and chooseTileType <= 85:
		activeTiles.add_child(cornerTileLeft.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		maxGifts += 3
	elif chooseTileType > 85:
		activeTiles.add_child(cornerTileRight.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		maxGifts += 3
	
	tiles = activeTiles.get_children()
	var newTile = tiles.get(tiles.size() - 1)
	connectingTile.connected += 1
	newTile.position = connectingTile.connectorEnd.global_position
	newTile.rotation = connectingTile.connectorEnd.global_rotation


func _on_beacon_body_entered(body: Node3D) -> void:
	print("player beaconed")
	player.stop = true
	player.mesh.visible = false
	$toLobby.start()


func _on_to_lobby_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")
