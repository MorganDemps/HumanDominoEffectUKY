# node for agency string

extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_String_mouse_entered() -> void:
	queue_free()
	get_parent().get_node('End').start()
