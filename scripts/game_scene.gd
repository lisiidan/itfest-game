extends Node2D

@onready var goal_board: Node2D = $GoalBoard
@onready var reagent_shelf: Node2D = $ReagentShelf
@onready var level_complete_menu: Control = $UI/LevelCompleteMenu
@onready var mixer_flask: Area2D = $MixerFlask

const LEVEL_COMPLETE_DELAY := 0.8
const LEVEL_FAILED_DELAY := 2.0
const LAST_NORMAL_LEVEL_INDEX := 2

var level_index := 0
var current_level: LevelData
var level_finished := false

func unlock_starting_reagents_for_journal():
	if current_level == null:
		return

	for reagent_name in current_level.reagents:
		var reagent_id = get_formula(reagent_name)
		JournalManager.unlock_entry(reagent_id)

func _input(event):
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		return_to_main_menu()

func _ready():
	level_index = GameState.selected_level_index
	add_to_group("game_controller")

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

func load_level(index: int):
	level_finished = false
	level_index = index
	GameState.selected_level_index = index

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
	unlock_starting_reagents_for_journal()
	goal_board.show_goal(current_level.intro_text)
	goal_board.setup_goals(current_level.goals, current_level.goal_results)

func clear_level_state():
	reagent_shelf.clear_shelf()
	mixer_flask.reset_flask()

	var cat = get_tree().get_first_node_in_group("cat")
	if cat and cat.has_method("reset_cat"):
		cat.reset_cat()

func _on_all_goals_completed():
	if level_finished:
		return

	level_finished = true
	await get_tree().create_timer(LEVEL_COMPLETE_DELAY).timeout

	if level_index == 9:
		level_complete_menu.show_for_game_complete()
		return

	level_complete_menu.show_for_level_complete(level_index)

func fail_level():
	if level_finished:
		return

	level_finished = true
	await get_tree().create_timer(LEVEL_FAILED_DELAY).timeout
	level_complete_menu.show_for_level_failed(level_index)

func go_to_next_level():
	if level_index == 9:
		return_to_main_menu()
		return

	var next_index := level_index + 1

	if next_index > LAST_NORMAL_LEVEL_INDEX:
		show_game_finished_menu()
		return

	load_level(next_index)

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

var map = {
	"hydrogen": "H2",
	"oxygen": "O2",
	"nitrogen": "N2",
	"chlorine": "Cl2",
	"carbon": "C",
	"sodium": "Na",
	"sulfur": "S",
	"calcium": "Ca",

	"water": "H2O",
	"sodium_hydroxide": "NaOH",
	"hydrochloric_acid": "HCl",
	#"sodium_chloride": "NaCl",
	"carbon_dioxide": "CO2",
	"sulfur_dioxide": "SO2",
	"carbonic_acid": "H2CO3",
	"sulfurous_acid": "H2SO3",
	"calcium_hydroxide": "Ca(OH)2",
	"calcium_oxide": "CaO",
	"sodium_sulfite": "NaSO3",
	"ammonia": "NH3",
	"nitric_oxide": "NO",
	"hydrogen_sulfide": "H2S",
	"sodium_oxide": "Na2O",
	"nitrogen_dioxide": "NO2",
	"nitric_acid": "HNO3"
}

func get_formula(name: String) -> String:
	name = name.to_lower()
	return map.get(name, name)
