extends Node2D

var current_level = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level = load("res://levels/Agency.tscn").instance()
	add_child(current_level)
	
func change_level(next_scene):
	print('bruh')
	current_level.queue_free()
	current_level = next_scene.instance()
	add_child(current_level)
