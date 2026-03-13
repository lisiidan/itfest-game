extends Panel

var reagent_id: String = ""

func setup(id: String):
	reagent_id = id
	$Label.text = id

func _get_drag_data(at_position):
	var preview = duplicate()
	set_drag_preview(preview)

	return {
		"reagent_id": reagent_id
	}
