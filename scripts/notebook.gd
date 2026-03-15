extends Area2D

@export var journal_ui_path: NodePath

var journal_ui: Control
var start_pos: Vector2
var hover := false

func _ready():
	journal_ui = get_node(journal_ui_path)
	start_pos = position

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		journal_ui.open_journal()

func _on_mouse_entered():
	if hover:
		return
	hover = true

	var tween = create_tween()
	tween.tween_property(self, "position", start_pos + Vector2(0, -20), 0.15)

func _on_mouse_exited():
	hover = false

	var tween = create_tween()
	tween.tween_property(self, "position", start_pos, 0.15)

func disable_notebook():
	visible = false
	input_pickable = false
	monitoring = false
	monitorable = false
	set_process(false)

func enable_notebook():
	visible = true
	input_pickable = true
	monitoring = true
	monitorable = true
	set_process(true)
