# domino level scene

extends Node2D

export (PackedScene) var Domino

var sorted_players = []
	
var turn = 0                          # whose turn is it, indexed from 0 on
var hand = [] 
var dominos = [] + gamestate.dominos
var self_num = 0                      # player's number, indexed from 1 on
var selected_domino = null            # currently selected domino
var center_num = 0                    # current round number
 
var path_ends = [0, 0, 0, 0, 0, 0, 0, 0] # last number on domino chain in each path
var end_dominos = [null, null, null, null, null, null, null, null] # last domino on domino chain in each path

var position_table = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# intialize character bubble icons around table
	var ind = 1
	
	for p in gamestate.players:
		sorted_players.append(p)
	sorted_players.sort()
	
	# setup each player one by one
	for player_id in sorted_players:
#		print("id: ", player_id)
#		print("elcitraps: ", gamestate.elcitraps[player_id])
#		print("traits: ", gamestate.hair[player_id], gamestate.face[player_id], gamestate.body[player_id])

		# initialize hair and face for board view
		var current = "Character Bubble"+str(ind)
		get_node(current+"/hair").set_texture(load("res://sprites/character_sprites/hair/"+str(gamestate.hair[player_id])+".png"))
		get_node(current+"/face").set_texture(load("res://sprites/character_sprites/faces/"+str(gamestate.face[player_id])+".png"))
		
		# initialize character looks in popup
		get_node(current+"/Score/Button/PopupDialog/hair").set_texture(load("res://sprites/character_sprites/hair/"+str(gamestate.hair[player_id])+".png"))
		get_node(current+"/Score/Button/PopupDialog/face").set_texture(load("res://sprites/character_sprites/faces/"+str(gamestate.face[player_id])+".png"))
		get_node(current+"/Score/Button/PopupDialog/body").set_texture(load("res://sprites/character_sprites/bodies/"+str(gamestate.body[player_id])+".png"))
		get_node(current+"/Score/Button/PopupDialog/Name_text").set_text(gamestate.players[player_id])

		# initalize elcitraps
		for i in range(len(gamestate.elcitraps[player_id])):
			get_node(current+"/Score/Button/PopupDialog/elcitrap"+str(i)).init((gamestate.elcitraps[player_id])[i])
			
		# set self number and make own path bubble visible
		if player_id == get_tree().get_network_unique_id():
			self_num = ind-1
			get_node("Path"+str(ind)).visible = true
		else:
			get_node("Path"+str(ind)).temp = true

		ind += 1
		
	# remove any unused character sprites
	for i in range(ind, 7):
		get_node("Character Bubble"+str(i)).queue_free()
		
	get_parent().get_node("AudioStreamPlayer").stream = load("res://audio/background/main.ogg")
	get_parent().get_node("AudioStreamPlayer").playing = true
	
	# add start game and next round buttons to host screen
	if get_tree().get_network_unique_id() == 1:
		$Start.visible = true
		$Next.visible = true
	
	$Turn.text = gamestate.players[1] + "'s\nTurn"
	
	dominos.erase([0, 0])
#	print(dominos)
	
	
func _on_Start_pressed() -> void:
	setup_dominos()
	
	$Start.queue_free()
	
# initialize everyone's dominos
func setup_dominos():
	# host domino set up
	draw_7()
	
	# tell everyone else to draw 7 dominos, in turn
	for p in gamestate.players:
		if p != 1:
			rpc_id(p, "get_starting_hand")

remote func get_starting_hand():
	draw_7()

# initialize 7 dominos from main deck on player's screen
func draw_7():
	for i in range(7):
		# get domino info
		var domino_nums = draw_domino()
		var domino = Domino.instance()
		var domino_title = str(domino_nums[1])+str(domino_nums[0])
		domino.get_node("Sprite").texture = load("res://sprites/dominos/"+domino_title+".png")
		add_child(domino)
		
		# set domino position
		if i < 4:
			domino.position = Vector2(700, 400*i - 600)
		else:
			domino.position = Vector2(950, 400*(i-4) - 600)
			
		# initialize domino
		domino.init(domino_nums[0], domino_nums[1], gamestate.domino_dict[domino_title][1], gamestate.domino_dict[domino_title][0], true)

# path set-up
func add_position(pos):
	position_table.append(pos)

# take a domino from the main deck
func draw_domino():
	var nums = dominos.pop_front()
#	print("len: ", len(dominos))
	if nums[0] < nums[1]:
		nums.invert()
#	print(nums, len(dominos))

	# update every player's deck to stay in sync
	rpc("update_deck")
	return nums
	
func select_domino(domino):
	selected_domino = domino
	
# update deck from other player's drawing a domino
remote func update_deck():
	var nums = dominos.pop_front()
#	print(nums, len(dominos))

# handles placing of domino onto a path
func place_domino(num):
	var flip = false
	
	# check if it is your turn and you have selected a domino
	if turn == self_num and selected_domino:
		# check if domino can be placed here
		if selected_domino.bottom_num == path_ends[num] or selected_domino.top_num == path_ends[num]:
			# flip domino if the top number matches instead of the bottom
			if selected_domino.bottom_num != path_ends[num]:
				selected_domino.init(selected_domino.top_num, selected_domino.bottom_num, selected_domino.top_element, selected_domino.bottom_element, false)
				selected_domino.get_node("Sprite").rotation_degrees = 180
				flip = true
				
			# check for alloy
			if end_dominos[num] and end_dominos[num].top_element != selected_domino.bottom_element:
				rpc("increment_alloys", self_num+1, gamestate.element_to_alloy[selected_domino.bottom_element])
				increment_alloys(self_num+1, gamestate.element_to_alloy[selected_domino.bottom_element])
				
			# check for footprint tile
			if selected_domino.top_num == selected_domino.bottom_num:
				var index = str(center_num)+str(selected_domino.bottom_num)
				rpc("increment_footprint_tiles", self_num+1, gamestate.footprint_title_table[index], gamestate.footprint_text_table[index])
				increment_footprint_tiles(self_num+1, gamestate.footprint_title_table[index], gamestate.footprint_text_table[index])
				
			# remove old domino on path if there was one
			if end_dominos[num]:
				end_dominos[num].queue_free()
			
			# place domino; update screen and update turn
			selected_domino.placed = true
			selected_domino.position = position_table[num]
			path_ends[num] = selected_domino.top_num
			end_dominos[num] = selected_domino
			
			turn = (turn+1)%len(gamestate.players)
			$Turn.text = gamestate.players[sorted_players[turn]] + "'s\nTurn"
			
			# if helped another player on their path, get a wellness bead
			if num < 6 and get_node("Path"+str(num+1)).temp == true:
				increment_wellness_beads(self_num+1)
				rpc("increment_wellness_beads", self_num+1)
				display_wellness_prompt()
				
				# remove the other player's path now that they have been helped
				rpc("remove_path", num+1)
				remove_path(num+1)
				
			# remove one's one path from others if no longer need help
			if num < 6:
				rpc("remove_path", num+1)
			
			# update other player screens
			rpc("update_domino_path", [selected_domino.bottom_num, selected_domino.top_num], [selected_domino.bottom_element, selected_domino.top_element], position_table[num], num, flip)
			
			# get new domino from deck
#			replace_domino()                   # UNCOMMENT IF WANT TO REPLACE DOMINOS

			selected_domino = null
			$Place.playing = true

# increment total score for player
func increment_total(num):
	var path = "Character Bubble"+str(num)+"/Score/Button/PopupDialog/Lydia_number"
	get_node(path).text = str(int(get_node(path).text) + 1)
	$Acquire.playing = true

# display wellness bead popup
func display_wellness_prompt():
	$AlloyPopup/Title.text = "You Got a..."
	$AlloyPopup/Alloy.text = "Wellness Bead!"
	$AlloyPopup/Info.text = "You helped someone on their path and so helped promote community wellness!"
	$AlloyPopup.visible = true

# increment wellness beads for player denoted by num
remote func increment_wellness_beads(num):
	var path = "Character Bubble"+str(num)+"/Score/Button/PopupDialog/Wellness_number"
	get_node(path).text = str(int(get_node(path).text) + 1)
	increment_total(num)
	
# increment alloys earned for player denoted by num
remote func increment_alloys(num, alloy):
	var path = "Character Bubble"+str(num)+"/Score/Button/PopupDialog/Alloy_number"
	get_node(path).text = str(int(get_node(path).text) + 1)
	increment_total(num)
	
	$AlloyPopup/Title.text = "Alloy Acquired!"
	$AlloyPopup/Alloy.text = alloy
	$AlloyPopup/Info.text = gamestate.alloy_table[alloy]
	$AlloyPopup.visible = true
	
# increment footprint tiles earned for player denoted by num
remote func increment_footprint_tiles(num, title, text):
	var path = "Character Bubble"+str(num)+"/Score/Button/PopupDialog/Footprint_number"
	get_node(path).text = str(int(get_node(path).text) + 1)
	increment_total(num)
	
	$AlloyPopup/Title.text = "Footprint Tile Acquired!"
	$AlloyPopup/Alloy.text = title
	$AlloyPopup/Info.text = text
	$AlloyPopup.visible = true
	
# update domino path for all players after a player places a domino
remote func update_domino_path(domino_nums, domino_elms, pos, path_num, flip):
	# remove old domino if exists
	if end_dominos[path_num]:
		end_dominos[path_num].queue_free()
	
	# create new placed domino
	var domino = Domino.instance()
	add_child(domino)
	domino.position = pos
	var domino_title = str(min(domino_nums[0], domino_nums[1]))+str(max(domino_nums[0], domino_nums[1]))
	domino.get_node("Sprite").texture = load("res://sprites/dominos/"+domino_title+".png")
	domino.init(domino_nums[0], domino_nums[1], domino_elms[0], domino_elms[1], true)
	domino.placed = true
	
	# update path
	path_ends[path_num] = domino_nums[1]
	end_dominos[path_num] = domino
	
	# flip domino sprite if necessary
	if flip:
		domino.get_node("Sprite").rotation_degrees = 180
	
	# change turn
	turn = (turn+1)%len(gamestate.players)
	$Turn.text = gamestate.players[sorted_players[turn]] + "'s\nTurn"
	
# replace placed domino with one from the deck
func replace_domino():
	var domino_nums = draw_domino()
	if domino_nums:
		var domino = Domino.instance()
		var domino_title = str(domino_nums[1])+str(domino_nums[0])
		domino.get_node("Sprite").texture = load("res://sprites/dominos/"+domino_title+".png")
		add_child(domino)
		domino.position = selected_domino.original_pos
		domino.init(domino_nums[0], domino_nums[1], gamestate.domino_dict[domino_title][1], gamestate.domino_dict[domino_title][0], true)
	else:
		return

# go to next round of play
remote func next_round():
	# remove all old dominos from screen
	var group_dominos = get_tree().get_nodes_in_group("dominos")
	for domino in group_dominos:
		domino.queue_free()
		
	# if we've completed round 5, end game
	if center_num >= 5:
		$Turn.text = "Game\nOver!"
		$End.text = "Winner: " + determine_winner() + "\n(Hover over faces to see stats.)"
		$End.visible = true
		center_num += 1
		return
		
	# randomize dominos
	dominos = [] + gamestate.dominos
	dominos.shuffle()
	
	# increment round number
	center_num += 1
	
	# remove center domino from deck
	dominos.erase([center_num, center_num])

	# reset domino paths
	path_ends = []
	for i in range(8):
		path_ends.append(center_num)
	end_dominos = [null, null, null, null, null, null, null, null]
	
	# load center domino
	var domino_title = "res://sprites/dominos/"+str(center_num)+str(center_num)+".png"
	$CentralDomino.get_node("Sprite").texture = load(domino_title)
	
	# reset path visibility
	for i in range(1, 7):
		if i != self_num + 1:
			get_node("Path"+str(i)).visible = false
	
# handle when next round button pressed by host
func _on_Next_pressed() -> void:
	# reset field for host
	next_round()
	
	# reset field for everyone else
	for p in gamestate.players:
		if p != 1:
			rpc_id(p, "next_round")

	# get new dominos from deck
	if center_num <= 5:
		setup_dominos()
		$NextSound.playing = true

# if player cannot play a domino on their paths
func _on_Help_pressed() -> void:
	if turn == self_num:
		# add their path to everyone else's screen
		rpc("add_path", self_num+1)
		
		# change turn
		turn = (turn+1)%len(gamestate.players)
		$Turn.text = gamestate.players[sorted_players[turn]] + "'s\nTurn"
		$NextSound.playing = true
	
# add player's path denoted by num to all player's screens
remote func add_path(num):
	turn = (turn+1)%len(gamestate.players)
	$Turn.text = gamestate.players[sorted_players[turn]] + "'s\nTurn"
	get_node("Path"+str(num)).visible = true
	
# remove player's path denoted by num from all player's screens
remote func remove_path(num):
	if get_node("Path"+str(num)).temp:
		get_node("Path"+str(num)).visible = false

func _on_Close_pressed() -> void:
	$AlloyPopup.visible = false
	
# return winner's name (could also be names depending on ties) based on highest total points
func determine_winner():
	var best_score = -1
	var winners = []
	for i in range(1, len(sorted_players)+1):
		var current_player = get_node("Character Bubble"+str(i)+"/Score/Button/PopupDialog")
		if int(current_player.get_node("Lydia_number").text) > best_score:
			winners = [current_player.get_node("Name_text").text]
			best_score = int(current_player.get_node("Lydia_number").text)
		elif int(current_player.get_node("Lydia_number").text) == best_score:
			winners.append(current_player.get_node("Name_text").text)
	var winner_text = ""
	for winner in winners:
		winner_text += winner
		winner_text += ", "
	winner_text.erase(winner_text.length() - 1, 1)
	winner_text.erase(winner_text.length() - 1, 1)
	return winner_text
