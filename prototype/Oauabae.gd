# node for movable oauabae

extends Area2D

func _physics_process(delta):
	position += (get_global_mouse_position() - position)

func _on_String_mouse_entered() -> void:
	$AnimatedSprite.animation = 'agencied'
