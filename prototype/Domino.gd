# node for domino on Domino Level

extends Node2D


export var top_num = 0
export var bottom_num = 0
export var top_element = ""
export var bottom_element = ""

var original_pos = null
var og_scale = 1.3
var selected = false
export var placed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# change domino appearance
	if not placed:
		add_to_group("dominos")
	original_pos = position

func init(bottom, top, bottom_elm, top_elm, initial):
	bottom_num = bottom
	top_num = top
	
	if not bottom_elm:
		bottom_element = ""
	else:
		bottom_element = bottom_elm
	if not top_elm:
		top_element = ""
	else:
		top_element = top_elm
	if initial:
		original_pos = self.position
	$Label.text = bottom_element + "\n" + str(bottom) + " | " + str(top) + "\n" + top_element


func _on_Area2D_mouse_entered() -> void:
	$Sprite.scale = Vector2(og_scale+0.05, og_scale+0.05)
func _on_Area2D_mouse_exited() -> void:
	$Sprite.scale = Vector2(og_scale, og_scale)


# click once to move domino with mouse, click anywhere after to drop domino back to original spot
func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
			if event.pressed:
				if not placed:
					selected = not selected
					if selected:
						get_parent().select_domino(self)
					
func _physics_process(delta):
	if selected and not placed:
		position += (get_global_mouse_position() - position)
	elif not placed:
		position = original_pos
