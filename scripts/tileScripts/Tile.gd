extends Node3D

signal collapsed

@onready var globals : global = get_node("/root/Global")
@onready var connectors := $control/connectors.get_children()
@onready var Collision := $control/Area3D
@onready var checkCollision := $control/Area3D
@onready var particle1 := $control/GPUParticles3D
@onready var particle2 := $control/GPUParticles3D2
@onready var particle3 := $control/GPUParticles3D3
@onready var goldenGifts := $control/goldenGifts

@export var giftAmount : int = 0
@export var type : String

var rng = RandomNumberGenerator.new()
var collapseTimer
var startDestruction := false
var latch := false


func _ready() -> void:
	#this is jank, but it works
	#so it WAS frame dependant. but physics process has fixed it
	await get_tree().physics_frame
	await get_tree().physics_frame
	var getCollisions = checkCollision.get_overlapping_bodies()
	if len(getCollisions) > 1:
		print("tile removed")
		queue_free()


func _process(delta: float) -> void:
	if startDestruction:
		collapseTimer = get_tree().create_timer(5)
		particle1.emitting = true
		if particle2 != null:
			particle2.emitting = true
		if particle3 != null:
			particle3.emitting = true
		await collapseTimer.timeout
		queue_free()
		collapsed.emit()
	
	if globals.collaseStarted and !latch and goldenGifts != null:
		goldenGifts.visible = true
		latch = true
