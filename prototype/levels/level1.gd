# quantum realm scene where player captures wavy elcitraps

extends Node

# Declare member variables here. Examples:
export (PackedScene) var Elcitrap
export var next_scene: PackedScene
export var total_captured = 0

export var trait_queue = [] + gamestate.traits

var players_ready = []

var narration_text = ["You now have the power to shape your future.",
"Now, use your Oauabae to help you see through the chaos!"]
var narration_count = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(15):
		trait_queue[i].append([i*60 + 100, 550])
		
	randomize()
	new_game()

func new_game():
	$StartTimer.start()
	$Narration.text = narration_text[0]
	$Narration/TextAnimationPlayer.play("Reveal", -1, 2)

# source: https://docs.godotengine.org/en/3.2/getting_started/step_by_step/your_first_game.html#enemy-scene
func _on_StartTimer_timeout():
#	print("start timer end")
	$ElcitrapTimer.start()
#	print("e timer start")

func _on_ElcitrapTimer_timeout():
	# if there are still uncaptured elcitraps, release one from edge of screen
	if len(trait_queue) > 0:
		
		# Choose a random location on Path2D.
		$EPath/EPathFollow.offset = randi()
		
		# Create a Mob instance and add it to the scene.
		var elcitrap = Elcitrap.instance()
		elcitrap.init(trait_queue[0])
		trait_queue.pop_front()
		add_child(elcitrap)
		
		# Set the mob's direction perpendicular to the path direction.
		var direction = $EPath/EPathFollow.rotation + PI / 2
		
		# Set the mob's position to a random location.
		elcitrap.position = $EPath/EPathFollow.position
		
		# Add some randomness to the direction/rotation.
		direction += rand_range(-PI / 4, PI / 4)
		elcitrap.rotation = direction
		
		# Set the velocity (speed & direction).
		elcitrap.linear_velocity = Vector2(rand_range(elcitrap.min_speed, elcitrap.max_speed), 0)
		elcitrap.linear_velocity = elcitrap.linear_velocity.rotated(direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if total_captured == 15:
		$EndTimer.start()
		total_captured = 16
		
func _on_EndTimer_timeout() -> void:
#	print('end timer end')
	
	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	else:
		ready_to_start(get_tree().get_network_unique_id())
	
remotesync func set_elcitraps(elcitraps):
	gamestate.elcitraps[get_tree().get_rpc_sender_id()] = elcitraps
	
remote func start_game():
	get_parent().change_level(next_scene)

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == gamestate.players.size():
		for p in gamestate.players:
			rpc_id(p, "start_game")
		start_game()

func _on_TextAnimationPlayer_animation_finished(anim_name: String) -> void:	
	if narration_count < len(narration_text):
		$Narration.text = narration_text[narration_count]
		$Narration/TextAnimationPlayer.play("Reveal", -1, 1.5)
		narration_count += 1
