# narration scene to introduce oauabae and agency to kids

extends Node

export var next_scene: PackedScene

var players_ready = []

# following text will be read out sequentially as narration
var narration_text = ["The magnifying glass will help you see things more closely, more clearly, more critically.",
"It looks like the letter 'O' for Oauabae. It has a little spark too, that's the energy of your mind!",
"Only you know the real you. Yep, only you know your real Oauabae. You get to decide using your own agency.",
"The world is full of strings, and this one in the middle of the screen is quite special.",
"It represents your agency, your ability to choose who you want to be.",
"You deserve to have a vision for your life. Go ahead and seize your agency with your Oauabae!"]

var narration_count = 0

func _ready() -> void:
	$Oauabae/AnimatedSprite.animation = "default"
	$Narration.text = "The magnifying glass you're controlling is you.                            Well, it's your you for this game."
	$Narration/TextAnimationPlayer.play("Reveal")
	
	get_parent().get_node("AudioStreamPlayer").stream = load("res://audio/background/quantum.ogg")
	get_parent().get_node("AudioStreamPlayer").playing = true

func _on_End_timeout() -> void:
	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	else:
		ready_to_start(get_tree().get_network_unique_id())
	
# tell all player's what each player's chosen elcitraps are
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

# advance narration or let player click on agency string
func _on_TextAnimationPlayer_animation_finished(anim_name: String) -> void:
	if narration_count == 3:
		$String.visible = true
		$String/AnimationPlayer.play("Color")
		
	if narration_count == len(narration_text):
		$String.input_pickable = true
	else:
		$Narration.text = narration_text[narration_count]
		$Narration/TextAnimationPlayer.play("Reveal")
		narration_count += 1
