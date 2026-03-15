extends Control

@onready var bg: TextureRect = $TextureRect
@onready var text_label: RichTextLabel = $RichTextLabel

var hover_timer := 0.0
var delay := 0.0
var pending_text := ""
var pending_pos := Vector2.ZERO
var waiting := false

const PADDING_LEFT := 30.0
const PADDING_RIGHT := 30.0
const PADDING_TOP := 30.0
const PADDING_BOTTOM := 30.0

const MIN_TEXT_WIDTH := 120.0
const MAX_TEXT_WIDTH := 260.0

func _ready() -> void:
	add_to_group("reagent_tooltip")
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	text_label.add_theme_color_override("default_color", Color(0.34, 0.17, 0.08))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.fit_content = false
	text_label.scroll_active = false

func _process(delta: float) -> void:
	if waiting:
		hover_timer += delta
		if hover_timer >= delay:
			waiting = false
			_show_now()

func show_tooltip(text: String, screen_pos: Vector2) -> void:
	pending_text = text
	pending_pos = screen_pos
	hover_timer = 0.0
	waiting = true

func hide_tooltip() -> void:
	waiting = false
	hide()

func _show_now() -> void:
	text_label.text = pending_text
	text_label.position = Vector2(PADDING_LEFT, PADDING_TOP)
	text_label.custom_minimum_size = Vector2.ZERO

	var estimated_width = _estimate_text_width(pending_text)
	var text_width = clampf(estimated_width, MIN_TEXT_WIDTH, MAX_TEXT_WIDTH)

	# сначала временно показываем, но невидимо, чтобы layout пересчитался корректно
	modulate.a = 0.0
	show()

	text_label.size = Vector2(text_width, 1.0)
	await get_tree().process_frame

	var text_height = text_label.get_content_height()
	if text_height < 1.0:
		text_height = 24.0

	text_label.size = Vector2(text_width, text_height)

	var tooltip_width = text_width + PADDING_LEFT + PADDING_RIGHT
	var tooltip_height = text_height + PADDING_TOP + PADDING_BOTTOM

	bg.position = Vector2.ZERO
	bg.size = Vector2(tooltip_width, tooltip_height)

	size = bg.size
	global_position = pending_pos

	modulate.a = 1.0
func _estimate_text_width(text: String) -> float:
	var longest_line := 0
	for line in text.split("\n"):
		longest_line = max(longest_line, line.length())

	return longest_line * 7.5
