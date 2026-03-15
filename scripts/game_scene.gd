extends Node2D

@onready var goal_board: Node2D = $GoalBoard
@onready var reagent_shelf: Node2D = $ReagentShelf
@onready var level_complete_menu: Control = $UI/LevelCompleteMenu

var level_index := 0
var current_level: LevelData
var max_level_count := 3
var level_finished := false

func _ready():
	goal_board.all_goals_completed.connect(_on_all_goals_completed)

	level_complete_menu.next_pressed.connect(_on_next_pressed)
	level_complete_menu.retry_pressed.connect(_on_retry_pressed)
	level_complete_menu.menu_pressed.connect(_on_menu_pressed)

	level_complete_menu.hide()
	load_level(level_index)

func _on_next_pressed():
	level_complete_menu.close_menu()
	go_to_next_level()

func _on_retry_pressed():
	level_complete_menu.close_menu()
	restart_level()

func _on_menu_pressed():
	level_complete_menu.close_menu()
	return_to_main_menu()

#func _ready():
	#goal_board.all_goals_completed.connect(_on_all_goals_completed)
	#level_complete_menu.hide()
	#load_level(level_index)

func load_level(index: int):
	level_finished = false

	var path = "res://assets/resources/level_data_%d.tres" % index
	if not ResourceLoader.exists(path):
		show_game_finished_menu()
		return

	current_level = load(path) as LevelData
	if current_level == null:
		push_error("Failed to load level: " + path)
		return

	clear_level_state()

	reagent_shelf.spawn_reagents(current_level.reagents)
	goal_board.show_goal(current_level.intro_text)
	goal_board.setup_goals(current_level.goals, current_level.goal_results)

func clear_level_state():
	reagent_shelf.clear_shelf()

func _on_all_goals_completed():
	if level_finished:
		return

	level_finished = true
	level_complete_menu.show_for_level_complete(level_index)

func go_to_next_level():
	level_index += 1
	#if(level_index > max_level_count):
		#level_index = 0
	load_level(level_index)

func restart_level():
	load_level(level_index)

func return_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func show_game_finished_menu():
	level_complete_menu.show_for_game_complete()

func parse_cell(cell: String) -> Dictionary:
	cell = cell.strip_edges()

	if cell == "-":
		return {"type":"neutral","result":""}

	if cell.begins_with("p:"):
		return {
			"type":"positive",
			"result":cell.substr(2)
		}

	if cell.begins_with("b:"):
		return {
			"type":"bonus",
			"result":cell.substr(2)
		}

	return {"type":"neutral","result":""}
