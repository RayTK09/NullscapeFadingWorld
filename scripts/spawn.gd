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
@onready var deathBox := $DEATHBOX

@export var player : player

var tileLimit : int = 3
var tileTypes : Array
var rng = RandomNumberGenerator.new()
var maxGifts : int = 0
var levelLoaded := false
var spawners : Array
var latch := false
var tilesSpawned : int = 0
var collapseStart := false
var collapseOneTile := false


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
		collapseStart = true
	#spawn tiles
	if tilesSpawned == tileLimit and !collapseStart:
		spawnTiles.stop()
		if !latch:
			player.stop = false
			latch = true
	if collapseStart and !collapseOneTile:
		collapse()
		collapseOneTile = true
	


func placeTiles(spawner):
	var tiles : Array = spawner.get_children()
	var validTiles : Array
	for x in tiles.size():
		var checkTile = tiles[x]
		for y in checkTile.connectors.size():
			if !checkTile.connectors[y].isConnected:
				validTiles.append(tiles[x])
				break
	var chooseTile = rng.randi_range(0, validTiles.size() - 1)
	
	#workaround to valid tiles returning nothing
	if validTiles == []:
		tilesSpawned -= 1
		return
	var connectingTile = validTiles[chooseTile]
	var connectorPoint : int
	for i in connectingTile.connectors.size():
		if !connectingTile.connectors[i].isConnected:
			connectorPoint = i
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
				#print(connectingTile.type)
			elif chooseTileType > 85 and chooseTileType <= 110:
				spawner.add_child(slopeDown.instantiate())
				#print(connectingTile.type)
			elif chooseTileType > 110:
				spawner.add_child(plus.instantiate())
			
			tiles = spawner.get_children()
			var newTile = tiles.get(tiles.size() - 1)
			if newTile.type == "slopeUp" and connectingTile.type == "slopeUp" or newTile.type == "slopeUp" and connectingTile.type == "slopeDown":
				tilesSpawned -= 1
				newTile.queue_free()
				return
			elif newTile.type == "slopeDown" and connectingTile.type == "slopeUp" or newTile.type == "slopeDown" and connectingTile.type == "slopeDown":
				tilesSpawned -= 1
				newTile.queue_free()
				return
			connectingTile.connectors[i].isConnected = true
			maxGifts += newTile.giftAmount
			newTile.global_position = connectingTile.connectors[connectorPoint].global_position
			newTile.global_rotation = connectingTile.connectors[connectorPoint].global_rotation
			newTile.collapsed.connect(collapse)
			return
		
	if connectingTile.connectors[connectorPoint].isConnected:
		tilesSpawned -= 1


func collapse():
	await get_tree().physics_frame
	var getTiles := [spawners[0].get_children(), spawners[1].get_children(), spawners[2].get_children(), spawners[3].get_children()]
	#note to self: if you want to get the amount of objects in an array, use SIZE() not MAX(), idiot.
	print("collapse")
	var getLongestPath = checkLongestTile(getTiles[0].size(), getTiles[1].size(), getTiles[2].size(), getTiles[3].size())
	if getLongestPath == 4:
		return
	var getSpawner : Array = getTiles[getLongestPath]
	print(getLongestPath)
	print(getSpawner)
	if getSpawner.size() == 1:
		collapse()
	getSpawner[getSpawner.size() - 1].startDestruction = true


func checkLongestTile(spawnerOne, spawnerTwo, spawnerThree, spawnerFour) -> int:
	if spawnerOne > spawnerTwo and spawnerOne > spawnerThree and spawnerOne > spawnerFour and spawnerOne != 1:
		return 0
	elif spawnerTwo > spawnerOne and spawnerTwo > spawnerThree and spawnerTwo > spawnerFour and spawnerTwo != 1:
		return 1
	elif spawnerThree > spawnerOne and spawnerThree > spawnerTwo and spawnerThree > spawnerFour and spawnerThree != 1:
		return 2
	elif spawnerFour > spawnerOne and spawnerFour > spawnerTwo and spawnerFour > spawnerThree and spawnerFour != 1: 
		return 3
	
	var listSpawners := [spawnerOne, spawnerTwo, spawnerThree, spawnerFour]
	for i in spawners.size():
		#print(listSpawners[i])
		if listSpawners[i] != 1:
			return i
	return 4




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
	print(tilesSpawned)
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


func _on_deathbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("tile"):
		deathBox.position -= 100
	if body.get("name") == "Player":
		player.mesh.ragdoll = true
		player.mesh.skeleton.active = true
		player.defaultCollision.disabled = true
		player.slideCollision.disabled = true
		player.acceleration = 0
		player.isDead = true
		player.deathTimer.start()
