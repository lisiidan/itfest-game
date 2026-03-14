extends Area2D

@onready var contents_label = $ContentsLabel
@onready var reaction_system: Node2D = $"../ReactionSystem"

var contents: Array[String] = []
var locked := false

func _ready():
	add_to_group("mixer_flask")

func contains_point(point: Vector2) -> bool:
	return $CollisionShape2D.shape.get_rect().has_point(to_local(point))

func _can_drop_data(at_position, data):
	return not locked and typeof(data) == TYPE_DICTIONARY and data.has("reagent_id")

func add_reagent(id: String):
	print("Added to flask:", id)

func _drop_data(at_position, data):
	if locked:
		return

	var reagent_id: String = data["reagent_id"]

	if contents.size() == 0:
		contents.append(reagent_id)
		update_ui()
		return

	if contents.size() == 1:
		contents.append(reagent_id)
		resolve_reaction()
		update_ui()
		return

func resolve_reaction():
	if contents.size() != 2:
		return

	locked = true

	var a = contents[0]
	var b = contents[1]
	var reaction = reaction_system.check_reaction(a, b)

	match reaction["type"]:
		"positive":
			contents = [reaction["result"]]
			show_feedback("New reagent discovered: " + reaction["result"])
		"bonus":
			contents = [reaction["result"]]
			show_feedback("New journal entry discovered")
		"neutral":
			show_feedback("No observable reaction")

func clear_flask():
	contents.clear()
	locked = false
	update_ui()

func update_ui():
	contents_label.text = "\n".join(contents)

func show_feedback(text: String):
	print(text)
