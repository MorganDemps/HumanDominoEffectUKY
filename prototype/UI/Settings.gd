# not quite implemented settings node

extends Node2D

func _on_Gear_Button_pressed() -> void:
	$Gear/PopupMenu.visible = !$Gear/PopupMenu.visible
