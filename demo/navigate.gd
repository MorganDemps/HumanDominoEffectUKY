extends Node2D

onready var nav : Navigation2D = $Navigation2D

var path : PoolVector2Array
var goal : Vector2
export var speed := 250

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			goal = get_viewport_transform().affine_inverse().xform( event.global_position )
			path = nav.get_simple_path($Character2D.position, goal, false)
#			$Line2D.points = PoolVector2Array(path)
#			$Line2D.show()
			
func _process(delta: float) -> void:
#	if !path:
#		$Line2D.hide()
#		return
	if path.size() > 0:
		var d: float = $Character2D.position.distance_to(path[0])
		if d > 10:
			$Character2D.position = $Character2D.position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)
