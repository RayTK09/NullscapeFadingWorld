extends Node3D

@onready var globals : global = get_node("/root/Global")
@onready var chooseClass := $Control/OptionButton


func _on_button_pressed() -> void:
	globals.chooseClass = chooseClass.get_selected_id()
	get_tree().change_scene_to_file("res://scenes/Tiles/spawn.tscn")
