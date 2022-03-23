# lobby scene where players enter the game

extends Control

func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]
		
	var ips = IP.get_local_addresses()
	print(ips)
	
	# set IP to any of the user's valid IP addresses
	for ip in ips:
		if ip.begins_with("192.168") or ip.begins_with("10") or ip.begins_with("172"):
			$Connect/IPAddress.text = ip
			break


func _on_host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect.hide()
	$Title.visible = false
	$SpeechBubble.visible = false
	$LevelSelect/Popup.visible = true
	$Connect/ErrorLabel.text = ""
	$Players/FindPublicIP.text = "IP: " + $Connect/IPAddress.text


func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true

	var player_name = $Connect/Name.text
	$Players/FindPublicIP.text = "IP: " + $Connect/IPAddress.text
	
	gamestate.join_game(ip, player_name)


func _on_connection_success():
	$Connect.hide()
	$Players.show()


func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")


func _on_game_ended():
	show()
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	$Players/List.clear()
#	$Players/List.add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		$Players/List.add_item(p)

	$Players/Start.disabled = not get_tree().is_network_server()


func _on_start_pressed():
	gamestate.begin_game()


func _on_find_public_ip_pressed():
	OS.shell_open("https://icanhazip.com/")

# handle which level to begin at / randomize dominos
func handle_level(level):
	gamestate.first_level = level
	
	for top in range(10):
		for bottom in range(top+1):
			gamestate.dominos.append([bottom, top])

	randomize()
	gamestate.random_seed = randi() % 10000000
	seed(gamestate.random_seed)
#	print(gamestate.random_seed)
	
	gamestate.dominos.shuffle()
#	print(gamestate.dominos)
	
	$LevelSelect/Popup.visible = false
	$Players.show()
	$Title.visible = true
	$SpeechBubble.visible = true
	var player_name = $Connect/Name.text
	gamestate.host_game(player_name)
	refresh_lobby()
	
func _on_Level1_pressed() -> void:
	handle_level("Agency")

func _on_Level2_pressed() -> void:
	handle_level("Pond")

func _on_Level3_pressed() -> void:
	handle_level("World")
