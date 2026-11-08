extends Node3D

@onready var tileStart1 := $startTile
@onready var tileStart2 := $startTile2
@onready var tileStart3 := $startTile3
@onready var tileStart4 := $startTile4
@onready var straightTile = preload('res://scenes/Tiles/straightTile.tscn')
@onready var cornerTileRight = preload("res://scenes/Tiles/corner_tile_right.tscn")
@onready var cornerTileLeft = preload("res://scenes/Tiles/corner_tile_left.tscn")
@onready var slopeUp = preload("res://scenes/Tiles/slope_up.tscn")
@onready var slopeDown = preload("res://scenes/Tiles/slope_down.tscn")
@onready var activeTiles := $activeTiles
@onready var globals : global = get_node("/root/Global")
@onready var beacon := $spawnTile/beacon

@export var player : player

var tileLimit : int = 50
var tileTypes : Array
var rng = RandomNumberGenerator.new()
var maxGifts : int = 0
var levelLoaded := false
var spawners : Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#AHHHHHHHH THIS TOOK WAY TOO LONG TO FIGURE OUT
	spawners = [tileStart1, tileStart2, tileStart3, tileStart4]
	for i in spawners.size():
		spawners[i].add_child(straightTile.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		var tiles = spawners[i].get_children()
	maxGifts += 16
	#spawn tiles
	for i in tileLimit:
		var chooseStarting = rng.randi_range(1, 4)
		match chooseStarting:
			1:
				placeTiles(spawners[0])
				print(1)
			2:
				placeTiles(spawners[1])
				print(2)
			3:
				placeTiles(spawners[2])
				print(3)
			4:
				placeTiles(spawners[3])
				print(4)
	
	beacon.monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if globals.collectedGifts == maxGifts:
		beacon.visible = true
		beacon.monitoring = true

func placeTiles(spawner):
	var tiles : Array
	tiles = spawner.get_children()
	var chooseTile = rng.randi_range(0, tiles.size() - 1)
	var connectingTile = tiles[chooseTile]
	#check to see if the tile that we are connecting to is already connected to a tile
	if connectingTile.connected == connectingTile.connectionPoints:
		#placeTiles(spawner)
		return
	#if it passes, create the tile
	# and choose a tile type to use
	var chooseTileType = rng.randi_range(0, 100)
	if chooseTileType <= 40:
		spawner.add_child(straightTile.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		maxGifts += 4 
	elif chooseTileType > 40 and chooseTileType <= 55:
		spawner.add_child(cornerTileLeft.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		maxGifts += 3
	elif chooseTileType > 55 and chooseTileType <= 70:
		spawner.add_child(cornerTileRight.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		maxGifts += 3
	elif chooseTileType > 70 and chooseTileType <= 85:
		spawner.add_child(slopeUp.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		maxGifts += 4
	elif chooseTileType > 85:
		spawner.add_child(slopeDown.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
		maxGifts += 4
	
	print(spawner)
	tiles = spawner.get_children()
	print(tiles)
	var newTile = tiles.get(tiles.size() - 1)
	connectingTile.connected += 1
	newTile.global_position = connectingTile.connectorEnd.global_position
	newTile.global_rotation = connectingTile.connectorEnd.global_rotation
	#check if tiles can be placed
	checkCollision(newTile)


func checkCollision(tile):
	await get_tree().process_frame
	var getCollisions = tile.checkCollision.get_overlapping_areas()
	if getCollisions != []:
		print(tile)
		print("tile removed")
		tile.queue_free()


func _on_beacon_body_entered(body: Node3D) -> void:
	print("player beaconed")
	player.stop = true
	player.mesh.visible = false
	$toLobby.start()


func _on_to_lobby_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")
