extends Node2D

@onready var goal_board: Node2D = $GoalBoard
@onready var reagent_shelf: Node2D = $ReagentShelf

var level_index := 0
var current_level: LevelData

func _ready():
	load_level(level_index)

func load_level(index: int):
	var path = "res://assets/resources/level_data_%d.tres" % index
	current_level = load(path) as LevelData

	reagent_shelf.spawn_reagents(current_level.reagents)
	goal_board.show_goal(current_level.intro_text)
	goal_board.setup_goals(current_level.goals, current_level.goal_results)

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
