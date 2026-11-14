class_name playerMesh
extends Node3D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var animationTree : AnimationTree = $AnimationTree

@export var player : player
@export var animationSpeed : int = 3



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match player.currentAnimation:
		1:
			animationTree['parameters/jumping/blend_amount'] = 0
			animationTree['parameters/idle to run/blend_amount'] -= delta * animationSpeed
			animationTree['parameters/ability/blend_amount'] = 0
		2:
			animationTree['parameters/jumping/blend_amount'] = 0
			animationTree['parameters/idle to run/blend_amount'] += delta * animationSpeed
			animationTree['parameters/ability/blend_amount'] = 0
		3:
			animationTree['parameters/jumping/blend_amount'] = -1
		4:
			animationTree['parameters/jumping/blend_amount'] = 1
		5:
			match player.playerClass:
				1:
					animationTree['parameters/ability/blend_amount'] = 1
				2:
					animationTree["parameters/ability/blend_amount"] = -1
					
	#ensure that lolbit doesnt become an eldritch horror
	if animationTree['parameters/idle to run/blend_amount'] > 1:
		animationTree['parameters/idle to run/blend_amount'] = 1
	elif animationTree['parameters/idle to run/blend_amount'] < 0:
		animationTree['parameters/idle to run/blend_amount'] = 0
		
	
