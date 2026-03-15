extends Control

signal next_pressed
signal retry_pressed
signal menu_pressed

@onready var title_label: Label = $Panel/TitleLabel
@onready var subtitle_label: Label = $Panel/SubtitleLabel
@onready var next_button: Button = $Panel/NextButton
@onready var retry_button: Button = $Panel/RetryButton
@onready var menu_button: Button = $Panel/MenuButton

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	next_button.pressed.connect(func(): next_pressed.emit())
	retry_button.pressed.connect(func(): retry_pressed.emit())
	menu_button.pressed.connect(func(): menu_pressed.emit())

func show_for_level_complete(level_index: int):
	title_label.text = "Experiment Complete"
	subtitle_label.text = "Level %d finished" % (level_index + 1)
	next_button.visible = true
	retry_button.visible = true
	menu_button.visible = true
	show()
	get_tree().paused = true

func show_for_level_failed(level_index: int):
	title_label.text = "Experiment Failed"
	subtitle_label.text = "Level %d failed" % (level_index + 1)
	next_button.visible = false
	retry_button.visible = true
	menu_button.visible = true
	show()
	get_tree().paused = true

func show_for_game_complete():
	title_label.text = "All Experiments Complete"
	subtitle_label.text = "You finished the game"
	next_button.visible = false
	retry_button.visible = true
	menu_button.visible = true
	show()
	get_tree().paused = true

func close_menu():
	hide()
	get_tree().paused = false
