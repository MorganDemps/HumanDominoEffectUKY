# character creation scene in Blombos Cave

extends Node2D

export var next_scene: PackedScene
export (PackedScene) var Elcitrap

export var hair_count = 24
export var face_count = 4
export var body_count = 12

var hair_num = 0
var face_num = 0
var body_num = 0

var players_ready = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Zoom")
	
	# populate elcitraps with data from previous scene
	for i in range(len(gamestate.elcitraps[get_tree().get_network_unique_id()])):
		var elcitrap = Elcitrap.instance()
		add_child(elcitrap)
		elcitrap.position = Vector2(60, 60*i + 200)
		elcitrap.init((gamestate.elcitraps[get_tree().get_network_unique_id()])[i])
		
	get_parent().get_node("AudioStreamPlayer").stream = load("res://audio/background/cave.ogg")
	get_parent().get_node("AudioStreamPlayer").playing = true


func mod(num, maximum):
	if num < 0:
		return maximum-1
	elif num > maximum-1:
		return 0
	else:
		return num

func _on_hair_left_pressed() -> void:
	hair_num = mod(hair_num - 1, hair_count)
	$hair.set_texture(load("res://sprites/character_sprites/hair/"+str(hair_num)+".png"))

func _on_hair_right_pressed() -> void:
	hair_num = mod(hair_num + 1, hair_count)
	$hair.set_texture(load("res://sprites/character_sprites/hair/"+str(hair_num)+".png"))

func _on_face_left_pressed() -> void:
	face_num = mod(face_num - 1, face_count)
	$face.set_texture(load("res://sprites/character_sprites/faces/"+str(face_num)+".png"))

func _on_face_right_pressed() -> void:
	face_num = mod(face_num + 1, face_count)
	$face.set_texture(load("res://sprites/character_sprites/faces/"+str(face_num)+".png"))
	
func _on_body_left_pressed() -> void:
	body_num = mod(body_num - 1, body_count)
	$body.set_texture(load("res://sprites/character_sprites/bodies/"+str(body_num)+".png"))

func _on_body_right_pressed() -> void:
	body_num = mod(body_num + 1, body_count)
	$body.set_texture(load("res://sprites/character_sprites/bodies/"+str(body_num)+".png"))

# wait for everyone to have pressed next to continue to next scene
func _on_next_pressed() -> void:
	rpc("set_features", hair_num, face_num, body_num)
	
	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	else:
		ready_to_start(get_tree().get_network_unique_id())
		
# set character features for player on every player's screen
remotesync func set_features(hair, face, body):
	gamestate.hair[get_tree().get_rpc_sender_id()] = hair
	gamestate.face[get_tree().get_rpc_sender_id()] = face
	gamestate.body[get_tree().get_rpc_sender_id()] = body
	
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

