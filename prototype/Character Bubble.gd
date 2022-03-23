# node for characters sitting around game board

extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


#func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
#	if event is InputEventMouseButton:
#		if event.pressed:
#			if $Score/Button/PopupDialog.visible:
#				$Score/Button/PopupDialog.visible = false
#				get_parent().get_node("AnimationPlayer").play("Zoom Out")
#			else:
#				$Score/Button/PopupDialog.visible = true
#				get_parent().get_node("AnimationPlayer").play("Zoom In")


# show or hide character stats
func _on_Area2D_mouse_entered() -> void:
	$Score/Button/PopupDialog.visible = true
func _on_Area2D_mouse_exited() -> void:
	$Score/Button/PopupDialog.visible = false
