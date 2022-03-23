tool
extends Area2D


onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready():
	anim_player.play("start")
	anim_player.play("pulse")
	pass

export var next_scene: PackedScene

func _on_area_entered(area: Area2D) -> void:
	teleport()
	
func _get_configuration_warning() -> String:
	return "The next scene property cannot be empty." if not next_scene else ""

func teleport() -> void:
	print("BRUH")
	anim_player.play("fade_in")
	yield(anim_player, "animation_finished")
	get_tree().change_scene_to(next_scene)



