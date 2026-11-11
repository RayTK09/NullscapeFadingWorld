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
@onready var plus = preload("res://scenes/Tiles/plus.tscn")
@onready var activeTiles := $activeTiles
@onready var globals : global = get_node("/root/Global")
@onready var beacon := $spawnTile/beacon
@onready var spawnTiles := $spawnTiles

@export var player : player

var tileLimit : int = 50
var tileTypes : Array
var rng = RandomNumberGenerator.new()
var maxGifts : int = 0
var levelLoaded := false
var spawners : Array
var latch := false
var tilesSpawned : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#AHHHHHHHH THIS TOOK WAY TOO LONG TO FIGURE OUT
	tileLimit *= globals.currentLevel
	globals.collectedGifts = 0
	maxGifts = 0
	spawners = [tileStart1, tileStart2, tileStart3, tileStart4]
	for i in spawners.size():
		spawners[i].add_child(straightTile.instantiate())
		var tiles = spawners[i].get_children()
	maxGifts += 16
	player.stop = true
	
	beacon.monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if globals.collectedGifts == maxGifts:
		beacon.visible = true
		beacon.monitoring = true
	#spawn tiles
	if tilesSpawned == tileLimit:
		spawnTiles.stop()
		player.stop = false


func placeTiles(spawner):
	var tiles = spawner.get_children()
	var chooseTile = rng.randi_range(0, tiles.size() - 1)
	var connectingTile = tiles[chooseTile]
	var connectorPoint : int
	for i in connectingTile.connectors.size():
		if !connectingTile.connectors[i].isConnected:
			connectingTile.connectors[i].isConnected = true
			connectorPoint = i
			print(connectingTile.connectors[i].isConnected)
			break
			 
	if connectingTile.connectors[connectorPoint].isConnected:
		tilesSpawned -= 1
		return
	
	#choose a tile type to use
	var chooseTileType = rng.randi_range(0, 120)
	if chooseTileType <= 40:
		spawner.add_child(straightTile.instantiate())
	elif chooseTileType > 40 and chooseTileType <= 55:
		spawner.add_child(cornerTileLeft.instantiate())
	elif chooseTileType > 55 and chooseTileType <= 70:
		spawner.add_child(cornerTileRight.instantiate())
	elif chooseTileType > 70 and chooseTileType <= 85:
		spawner.add_child(slopeUp.instantiate())
	elif chooseTileType > 85 and chooseTileType <= 110:
		spawner.add_child(slopeDown.instantiate())
	elif chooseTileType > 110:
		spawner.add_child(plus.instantiate())
	
	tiles = spawner.get_children()
	var newTile = tiles.get(tiles.size() - 1)
	maxGifts += newTile.giftAmount
	newTile.global_position = connectingTile.connectors[connectorPoint].global_position
	newTile.global_rotation = connectingTile.connectors[connectorPoint].global_rotation
	



func _on_beacon_body_entered(body: Node3D) -> void:
	print("player beaconed")
	player.stop = true
	player.mesh.visible = false
	$toLobby.start()


func _on_to_lobby_timeout() -> void:
	globals.currentLevel += 1
	get_tree().reload_current_scene()


func _on_spawn_platforms_timeout() -> void:
	tilesSpawned += 1
	#print(tilesSpawned)
	var chooseStarting = rng.randi_range(1, 4)
	match chooseStarting:
		1:
			placeTiles(spawners[0])
		2:
			placeTiles(spawners[1])
		3:
			placeTiles(spawners[2])
		4:
			placeTiles(spawners[3])


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
