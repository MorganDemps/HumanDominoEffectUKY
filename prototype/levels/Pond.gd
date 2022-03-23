# koi pond venn diagram scene

extends Node2D

export var next_scene: PackedScene

var choices = [] + gamestate.choices
var choice_ind = 0

var yellow_selected = false
var blue_selected = false
var red_selected = false

var players_ready = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Choice.text = choices[choice_ind][1]
	$Stone/stone.animation = choices[choice_ind][0]
	
	get_parent().get_node("AudioStreamPlayer").stream = load("res://audio/background/pond.ogg")
	get_parent().get_node("AudioStreamPlayer").playing = true
	
# handles users area of venn diagram selection
func handle_choice(area):
	
	# if the user has completed all basic choices, move on to advanced choices
	if choice_ind == 7 and choices[choice_ind][0] == area:
		$Popup.visible = true
		$Health.text = "Health"
		$Liberty.text = "Liberty"
		$Happiness.text = "Happiness"
		
	# if we're at the end of the choice list, tell host we're done
	if choice_ind == len(choices) - 1:
		if not get_tree().is_network_server():
			# Tell server we are ready to start.
			rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
		else:
			ready_to_start(get_tree().get_network_unique_id())
		
	# correct choice
	elif choices[choice_ind][0] == area:
		choice_ind += 1
		$Choice.text = choices[choice_ind][1]
		$Indicator.text = "Correct!"
		$Correct_num.text = str(int($Correct_num.text) + 1)
		change_stone(choices[choice_ind][0])
		$CorrectSound.playing = true
		
	# incorrect choice
	else:
		$Indicator.text = "Try again!"
		$IncorrectSound.playing = true
		
func change_stone(area):
	$Stone/stone.animation = area


# handle different venn diagram section clicks

func _on_y_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not blue_selected and not red_selected:
		handle_choice("y")

func _on_b_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not yellow_selected and not red_selected:
		handle_choice("b")

func _on_r_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not yellow_selected and not blue_selected:
		handle_choice("r")
		
func _on_yb_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not red_selected:
		handle_choice("yb")

func _on_yr_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not blue_selected:
		handle_choice("yr")

func _on_br_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and not yellow_selected:
		handle_choice("br")

func _on_ybr_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		handle_choice("ybr")


# make circles bigger / smaller with mouse hovering

func _on_y_area_mouse_entered() -> void:
	$y_ring.scale = Vector2(1.4, 1.4)
	yellow_selected = true

func _on_y_area_mouse_exited() -> void:
	$y_ring.scale = Vector2(1.35, 1.35)
	yellow_selected = false

func _on_b_area_mouse_entered() -> void:
	$b_ring.scale = Vector2(1.4, 1.4)
	blue_selected = true

func _on_b_area_mouse_exited() -> void:
	$b_ring.scale = Vector2(1.35, 1.35)
	blue_selected = false

func _on_r_area_mouse_entered() -> void:
	$r_ring.scale = Vector2(1.4, 1.4)
	red_selected = true

func _on_r_area_mouse_exited() -> void:
	$r_ring.scale = Vector2(1.35, 1.35)
	red_selected = false


func _on_Button_pressed() -> void:
	$Popup.visible = false
	

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
