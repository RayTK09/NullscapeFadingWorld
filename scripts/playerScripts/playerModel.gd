class_name playerMesh
extends Node3D

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var animationTree : AnimationTree = $AnimationTree
@onready var skeleton := $Skeleton3D/PhysicalBoneSimulator3D

@export var player : player
@export var animationSpeed : int = 3
@export var ragdoll := false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ragdoll:
		skeleton.physical_bones_start_simulation()
		player.camPivotX.global_position = $"Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Body".global_position
	else:
		match player.setAnimation:
			player.state.IDLE:
				animationTree['parameters/idle to run/blend_amount'] -= delta * animationSpeed
				animationTree['parameters/jumping/blend_amount'] = 0
				animationTree['parameters/ability/blend_amount'] = 0
			player.state.RUN:
				animationTree['parameters/idle to run/blend_amount'] += delta * animationSpeed
				animationTree['parameters/jumping/blend_amount'] = 0
				animationTree['parameters/ability/blend_amount'] = 0
			player.state.JUMP:
				animationTree['parameters/jumping/blend_amount'] = -1
				if !player.classes.isCharging:
					animationTree['parameters/ability/blend_amount'] = 0
			player.state.FALL:
				animationTree['parameters/jumping/blend_amount'] = 1
				if !player.classes.isCharging:
					animationTree['parameters/ability/blend_amount'] = 0
			player.state.CHARGE:
				animationTree['parameters/ability/blend_amount'] = 1
			player.state.DIVE:
				animationTree["parameters/ability/blend_amount"] = -1
						
		#ensure that lolbit doesnt become an eldritch horror
		if animationTree['parameters/idle to run/blend_amount'] > 1:
			animationTree['parameters/idle to run/blend_amount'] = 1
		elif animationTree['parameters/idle to run/blend_amount'] < 0:
			animationTree['parameters/idle to run/blend_amount'] = 0
