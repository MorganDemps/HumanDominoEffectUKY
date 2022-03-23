# node for static elcitrap on choosing personality screen

extends RigidBody2D

var current_type = null
var original_pos = Vector2(0,0)
var selected = false
var t = 0.0

var anim_table = {"red": "arts", "green": "science", "blue": "humanities"}

# Called when the node enters the scene tree for the first time.
func _ready():
	original_pos = self.position
	
func init(type, pos):
	$AnimatedSprite.animation = type[0]
	$Label.text = type[1]
	current_type = type
	original_pos = pos
	$PopupDialog/AnimatedSprite.animation = anim_table[current_type[0]]

func _on_CapturedElcitrap_mouse_entered() -> void:
	if not selected:
		$PopupDialog.visible = true

func _on_CapturedElcitrap_mouse_exited() -> void:
	$PopupDialog.visible = false

# when clicked add to chosen elcitraps or remove from chosen elcitraps
func _on_CapturedElcitrap_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if selected or len(get_parent().selected) < 5:
				selected = not selected
			if selected:
				self.position = Vector2(500 + rand_range(-125, 125), 300 + rand_range(-125, 125))
				get_parent().selected.append(current_type)
				$Select.playing = true
				
			if not selected:
				self.position = original_pos
				var ind = get_parent().selected.find(current_type)
				get_parent().selected.remove(ind)
				$Deselect.playing = true
