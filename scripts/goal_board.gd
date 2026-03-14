extends Panel

@onready var goal_text: RichTextLabel = $GoalText

var full_text := ""
var visible_chars := 0
var timer := 0.0
var typing_speed := 0.04
var is_typing := false

func show_goal(text: String):
	full_text = text
	visible_chars = 0
	timer = 0.0
	is_typing = true
	goal_text.text = ""

func _process(delta: float) -> void:
	if not is_typing:
		return

	timer += delta

	while timer >= typing_speed:
		timer -= typing_speed
		visible_chars += 1
		goal_text.text = full_text.substr(0, visible_chars)

		if visible_chars >= full_text.length():
			is_typing = false
			break
