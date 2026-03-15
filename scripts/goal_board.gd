extends Node2D

signal all_goals_completed

@onready var goal_text: RichTextLabel = $GoalText
@onready var goals_container: Node2D = $GoalsContainer

var goal_labels: Array[RichTextLabel] = []
var goal_results: Array[String] = []
var completed: Array[bool] = []

var table_font = preload("res://assets/fonts/EraserRegular.ttf")

var typing_speed := 0.04
var timer := 0.0

var header_full_text := ""
var header_visible_chars := 0

var goal_full_texts: Array[String] = []
var goal_visible_chars: Array[int] = []

# "header", "goal", "idle"
var typing_mode := "idle"
var current_goal_index := -1

var goal_strike_lines: Array[ColorRect] = []

func show_goal(text: String):
	header_full_text = text
	header_visible_chars = 0
	timer = 0.0
	typing_mode = "header"
	current_goal_index = -1
	goal_text.text = ""

	for i in range(goal_labels.size()):
		goal_labels[i].text = ""
		goal_visible_chars[i] = 0
		goal_labels[i].modulate = Color(1, 1, 1, 1)

func setup_goals(goals: Array[String], results: Array[String]):
	goal_strike_lines.clear()
	goal_results = results
	completed.resize(results.size())
	completed.fill(false)

	for child in goals_container.get_children():
		child.queue_free()

	goal_labels.clear()
	goal_full_texts.clear()
	goal_visible_chars.clear()

	var y := 0.0

	for i in range(goals.size()):
		var label := RichTextLabel.new()
		label.text = ""
		label.position = Vector2(0, y)
		label.size = Vector2(goal_text.size.x, 200)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.scroll_active = false
		label.fit_content = true
		label.bbcode_enabled = false

		label.add_theme_font_override("normal_font", table_font)
		label.add_theme_font_size_override("normal_font_size", 28)

		goals_container.add_child(label)
		goal_labels.append(label)

		var line := ColorRect.new()
		line.color = Color(0.85, 0.85, 0.85, 0.95)
		line.position = Vector2(18, y + 18)
		line.size = Vector2(0, 3)
		goals_container.add_child(line)
		goal_strike_lines.append(line)

		var full_line := "• " + goals[i]
		goal_full_texts.append(full_line)
		goal_visible_chars.append(0)

		label.text = full_line
		await get_tree().process_frame
		y += label.get_content_height() + 8
		label.text = ""

func _process(delta: float) -> void:
	if typing_mode == "idle":
		return

	timer += delta

	while timer >= typing_speed:
		timer -= typing_speed

		if typing_mode == "header":
			header_visible_chars += 1
			goal_text.text = header_full_text.substr(0, header_visible_chars)

			if header_visible_chars >= header_full_text.length():
				if goal_labels.size() > 0:
					typing_mode = "goal"
					current_goal_index = 0
				else:
					typing_mode = "idle"

		elif typing_mode == "goal":
			if current_goal_index < 0 or current_goal_index >= goal_labels.size():
				typing_mode = "idle"
				return

			goal_visible_chars[current_goal_index] += 1

			var full := goal_full_texts[current_goal_index]
			var visible := goal_visible_chars[current_goal_index]

			goal_labels[current_goal_index].text = full.substr(0, visible)

			if visible >= full.length():
				current_goal_index += 1
				if current_goal_index >= goal_labels.size():
					typing_mode = "idle"

func check_goal(result: String):
	for i in range(goal_results.size()):
		if goal_results[i] == result and not completed[i]:
			completed[i] = true
			await complete_goal(i)

			if are_all_goals_completed():
				all_goals_completed.emit()
			break

func are_all_goals_completed() -> bool:
	if completed.is_empty():
		return false

	for value in completed:
		if not value:
			return false
	return true

func complete_goal(i: int):
	var plain_text = goal_full_texts[i]
	if plain_text.begins_with("• "):
		plain_text = plain_text.substr(2)

	goal_full_texts[i] = "✓ " + plain_text
	goal_labels[i].text = goal_full_texts[i]
	goal_labels[i].modulate = Color(0.6, 0.6, 0.6, 1.0)

	await get_tree().process_frame

	var target_width = goal_labels[i].get_content_width()
	if target_width <= 0:
		target_width = 220

	var line = goal_strike_lines[i]
	line.size.x = 0

	var tween = create_tween()
	tween.tween_property(line, "size:x", target_width, 0.25)
	await tween.finished
