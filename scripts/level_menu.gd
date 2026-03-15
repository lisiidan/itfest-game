extends Control

@onready var level_1_button: Button = $Level1
@onready var level_2_button: Button = $Level2
@onready var level_3_button: Button = $Level3
@onready var back_button: Button = $Back

func _ready() -> void:
	level_1_button.pressed.connect(_on_level_1_pressed)
	level_2_button.pressed.connect(_on_level_2_pressed)
	level_3_button.pressed.connect(_on_level_3_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_level_1_pressed() -> void:
	_open_level(0)

func _on_level_2_pressed() -> void:
	_open_level(1)

func _on_level_3_pressed() -> void:
	_open_level(2)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _open_level(index: int) -> void:
	GameState.selected_level_index = index
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
