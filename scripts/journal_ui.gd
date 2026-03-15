extends Control

var journal_font = preload("res://assets/fonts/Jurnal_font.ttf")
var bold_journal_font = preload("res://assets/fonts/ByteBounce.ttf")
@export var notebook_path: NodePath
@export var entries: Array[JournalEntryData] = []

@onready var dim: ColorRect = $Dim
@onready var notebook_panel: TextureRect = $NotebookPanel
@onready var entries_list: GridContainer = $NotebookPanel/EntriesList
@onready var title_label: Label = $NotebookPanel/EntryPage/Title
@onready var body_label: RichTextLabel = $NotebookPanel/EntryPage/Body

var notebook
var entry_map := {}
var current_entry_id := ""
var entry_buttons := {}

func _ready():
	hide()
	notebook = get_node(notebook_path)

	for entry in entries:
		if entry != null and entry.reagent_id != "":
			entry_map[entry.reagent_id] = entry

func open_journal():
	show()
	if notebook:
		notebook.disable_notebook()
	refresh_entries()

func close_journal():
	hide()
	if notebook:
		notebook.enable_notebook()

func show_locked_entry():
	title_label.text = "???"
	body_label.text = "This substance has not been discovered yet."

func refresh_entries():
	for child in entries_list.get_children():
		child.queue_free()
	entry_buttons.clear()
	
	var unlocked = JournalManager.get_unlocked_entries()

	for entry in entries:
		if entry == null or entry.reagent_id == "":
			continue

		var is_unlocked = JournalManager.is_unlocked(entry.reagent_id)

		var button := Button.new()
		button.text = entry.reagent_id if is_unlocked else "???"
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 8)
		button.add_theme_font_override("font", journal_font)
		button.add_theme_color_override("font_color", Color(0.23, 0.18, 0.12))
		if is_unlocked:
			button.pressed.connect(func(): show_entry(entry.reagent_id))
		else:
			button.pressed.connect(func(): show_locked_entry())

		entries_list.add_child(button)
		entry_buttons[entry.reagent_id] = button

	var first_unlocked := ""

	for entry in entries:
		if entry != null and JournalManager.is_unlocked(entry.reagent_id):
			first_unlocked = entry.reagent_id
			break

	if current_entry_id != "" and JournalManager.is_unlocked(current_entry_id):
		show_entry(current_entry_id)
	elif first_unlocked != "":
		show_entry(first_unlocked)
	else:
		title_label.text = "No entries"
		body_label.text = ""

func show_entry(entry_id: String):
	if not entry_map.has(entry_id):
		return

	current_entry_id = entry_id
	var entry: JournalEntryData = entry_map[entry_id]

	title_label.text = entry.title
	body_label.text = entry.body
	
	title_label.add_theme_font_override("font", journal_font)
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color(0.23, 0.18, 0.12))
	
	body_label.add_theme_font_override("bold_font", bold_journal_font)
	body_label.add_theme_font_override("normal_font", journal_font)
	body_label.add_theme_font_size_override("normal_font_size", 8)
	body_label.add_theme_font_size_override("bold_font_size", 16)
	body_label.add_theme_color_override("default_color", Color(0.23, 0.18, 0.12))
	update_entry_button_styles()

func _input(event):
	if not visible:
		return

	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()

		if dim.get_global_rect().has_point(mouse_pos) and not notebook_panel.get_global_rect().has_point(mouse_pos):
			close_journal()

func update_entry_button_styles():
	for entry_id in entry_buttons.keys():
		var button: Button = entry_buttons[entry_id]

		if entry_id == current_entry_id:
			button.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
			button.modulate = Color(1.0, 0.95, 0.75, 1.0)
		else:
			button.add_theme_color_override("font_color", Color(0.23, 0.18, 0.12))
			button.modulate = Color(1, 1, 1, 1)
