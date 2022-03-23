# node for domino path bubble

extends Sprite

export var num = 0
export var temp = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().add_position(self.position)

# handle placing domino if domino is placed on to path
func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			get_parent().place_domino(num)

func _on_Area2D_mouse_entered() -> void:
	self.scale = Vector2(0.23, 0.23)
func _on_Area2D_mouse_exited() -> void:
	self.scale = Vector2(0.2, 0.2)
