extends Control

@onready var play_button: Button = $Play
@onready var sandbox_button: Button = $Sandbox
@onready var quit_button: Button = $Exit

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	sandbox_button.pressed.connect(_on_sandbox_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	GameState.selected_level_index = 0
	get_tree().change_scene_to_file("res://scenes/level_menu.tscn")

func _on_sandbox_pressed() -> void:
	GameState.selected_level_index = 9
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
