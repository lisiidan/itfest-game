extends Node2D

@onready var reagent_shelf: Control = $UI/LabUI/ReagentShelf
@onready var goal_board: Panel = $UI/GoalBoard

var level_index := 0
var current_level: LevelData

func _ready():
	load_level(level_index)

func load_level(index: int):
	var path = "res://assets/resources/level_data_%d.tres" % index
	current_level = load(path) as LevelData

	reagent_shelf.spawn_reagents(current_level.reagents)
	goal_board.show_goal(current_level.goal_text)
