# node for elcitrap in elcitrap selection scene

extends RigidBody2D

func init(type):
	$AnimatedSprite.animation = type[0]
	$Label.text = type[1]
	$PopupDialog/Label.text = type[1]
