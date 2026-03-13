extends Panel

var contents: Array[String] = []

func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("reagent_id")

func _drop_data(at_position, data):
	var reagent_id = data["reagent_id"]
	contents.append(reagent_id)
	print("Beaker contents: ", contents)
