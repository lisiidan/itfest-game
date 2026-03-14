extends Panel

var reagent_id: String = ""

func setup(sprite_name: String):
	reagent_id = get_formula(sprite_name)
	$Label.text = reagent_id
	$TextureRect.texture = load("res://assets/sprites/reagentsSprites/" + sprite_name + ".png")

func _get_drag_data(at_position):
	var preview = duplicate()
	set_drag_preview(preview)

	return {
		"reagent_id": reagent_id
	}

func get_formula(name: String) -> String:
	name = name.to_lower()

	var map = {
		"hydrogen": "H2",
		"oxygen": "O2",
		"nitrogen": "N2",
		"chlorine": "Cl2",
		"carbon": "C",
		"sodium": "Na",
		"sulfur": "S",
		"calcium": "Ca",

		"water": "H2O",
		"sodium_hydroxide": "NaOH",
		"hydrochloric_acid": "HCl",
		"sodium_chloride": "NaCl",
		"carbon_dioxide": "CO2",
		"sulfur_dioxide": "SO2",
		"carbonic_acid": "H2CO3",
		"sulfurous_acid": "H2SO3",
		"calcium_hydroxide": "Ca(OH)2",
		"calcium_oxide": "CaO",
		"sodium_sulfite": "NaSO3",
		"ammonia": "NH3",
		"nitric_oxide": "NO",
		"nitrogen_dioxide": "NO2",
		"nitric_acid": "HNO3"
	}

	return map.get(name, name)
