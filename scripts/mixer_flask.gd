extends Panel

@onready var contents_label = $ContentsLabel
@onready var reaction_system = $"../../../ReactionSystem"

var contents: Array[String] = []

func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("reagent_id")

func _drop_data(at_position, data):
	var reagent_id = data["reagent_id"]
	contents.append(reagent_id)

	var reaction = reaction_system.check_reaction(contents)

	if reaction != null:
		match reaction["type"]:
			"positive":
				contents = [reaction["result"]]
			"catastrophic":
				contents.clear()
			"neutral":
				pass

	contents_label.text = "\n".join(contents)
