# node for moving elcitrap wave

extends RigidBody2D


# Declare member variables here. Examples:
export var min_speed = 150  # Minimum speed range.
export var max_speed = 250  # Maximum speed range.


var current_type = null
var captured = false
var end_pos = null

var t = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func init(type):
	$AnimatedSprite.animation = type[0]
	$Label.text = type[1]
	current_type = type
	if len(type) > 2:
		end_pos = type[2]
	
# recycle elcitrap into queue when it leaves the screen
func _on_VisibilityNotifier2D_screen_exited():
	get_parent().trait_queue.append(current_type)
	queue_free()

# if elcitrap has been captured, play captured animation
func _physics_process(delta):
	if captured:
		$AnimatedSprite.stop()
		$AnimatedSprite.animation = "static_" + current_type[0]
		$AnimatedSprite.scale.x = 0.3
		$Label.visible = true
		self.rotation = 0
		self.linear_velocity = Vector2(0, 0)
		
		t += delta * 0.05
		
		self.position = self.position.linear_interpolate(Vector2(end_pos[0], end_pos[1]), t)

# capture elcitrap when mouse hovers over
func _on_Elcitrap1_mouse_entered() -> void:
	if not captured:
		get_parent().total_captured += 1
	captured = true
