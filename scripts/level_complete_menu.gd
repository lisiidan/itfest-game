extends Control

signal next_pressed
signal retry_pressed
signal menu_pressed

@onready var background: TextureRect = $TextureRect
@onready var title_label: Label = $TitleLabel
@onready var next_button: Button = $NextButton
@onready var retry_button: Button = $RetryButton
@onready var menu_button: Button = $MenuButton

var texture_win = preload("res://assets/sprites/level_complete_menu.png")
var texture_fail = preload("res://assets/sprites/menu_failed.png")

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	next_button.pressed.connect(func(): next_pressed.emit())
	retry_button.pressed.connect(func(): retry_pressed.emit())
	menu_button.pressed.connect(func(): menu_pressed.emit())

func show_for_level_complete(level_index: int):
	background.texture = texture_win
	title_label.text = "Experiment Complete"

	next_button.visible = true
	retry_button.visible = true
	menu_button.visible = true

	show()
	get_tree().paused = true

func show_for_level_failed(level_index: int):
	background.texture = texture_fail
	title_label.text = "Experiment Failed"

	next_button.visible = false
	retry_button.visible = true
	menu_button.visible = true

	show()
	get_tree().paused = true

func show_for_game_complete():
	#background.texture = texture_game_complete
	title_label.text = "All Experiments Complete"

	next_button.visible = false
	retry_button.visible = false
	menu_button.visible = true

	show()
	get_tree().paused = true

func close_menu():
	hide()
	get_tree().paused = false
