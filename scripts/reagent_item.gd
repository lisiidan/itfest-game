extends Area2D

static var currently_dragged: Area2D = null

var reagent_id: String = ""
var dragging := false
var drag_offset := Vector2.ZERO
var start_position := Vector2.ZERO
var original_z := 0
var original_scale := Vector2.ONE

func _ready():
	start_position = global_position
	original_z = z_index
	original_scale = scale

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if currently_dragged != null:
			return

		currently_dragged = self
		dragging = true
		drag_offset = global_position - get_global_mouse_position()

		scale = original_scale * 1.15
		z_index = 100

func _input(event):
	if dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false

		if currently_dragged == self:
			currently_dragged = null

		scale = original_scale
		z_index = original_z

		var mouse_pos = get_global_mouse_position()

		var flask = get_tree().get_first_node_in_group("mixer_flask")
		if flask and flask.contains_point(mouse_pos):
			flask.add_reagent(reagent_id)

		reset_position()

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset

func reset_position():
	global_position = start_position
func setup(sprite_name: String):
	reagent_id = get_formula(sprite_name)
	$Label.text = reagent_id
	$TextureRect.texture = load("res://assets/sprites/reagentsSprites/" + sprite_name + ".png")


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
