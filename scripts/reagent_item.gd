extends Area2D

static var currently_dragged: Area2D = null

var reagent_id: String = ""
var reagent_description: String = ""
var dragging := false
var drag_offset := Vector2.ZERO
var start_position := Vector2.ZERO
var original_z := 0
var original_scale := Vector2.ONE

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
	#"sodium_chloride": "NaCl",
	"carbon_dioxide": "CO2",
	"sulfur_dioxide": "SO2",
	"carbonic_acid": "H2CO3",
	"sulfurous_acid": "H2SO3",
	"calcium_hydroxide": "Ca(OH)2",
	"calcium_oxide": "CaO",
	"sodium_sulfite": "NaSO3",
	"ammonia": "NH3",
	"nitric_oxide": "NO",
	"hydrogen_sulfide": "H2S",
	"sodium_oxide": "Na2O",
	"nitrogen_dioxide": "NO2",
	"nitric_acid": "HNO3"
}

var reagent_descriptions = {
	"H2": "Hydrogen\nAtomic number: 1\nMolar mass: 2.02 g/mol\nState: Gas",
	"O2": "Oxygen\nAtomic number: 8\nMolar mass: 32 g/mol\nState: Gas",
	"N2": "Nitrogen\nAtomic number: 7\nMolar mass: 28 g/mol\nState: Gas",
	"Cl2": "Chlorine\nAtomic number: 17\nMolar mass: 70.9 g/mol\nState: Gas",
	"C": "Carbon\nAtomic number: 6\nMolar mass: 12 g/mol\nState: Solid",
	"Na": "Sodium\nAtomic number: 11\nMolar mass: 23 g/mol\nState: Solid",
	"S": "Sulfur\nAtomic number: 16\nMolar mass: 32 g/mol\nState: Solid",
	"Ca": "Calcium\nAtomic number: 20\nMolar mass: 40 g/mol\nState: Solid",

	"H2O": "Water\nMolar mass: 18 g/mol\nState: Liquid",
	"NaOH": "Sodium Hydroxide\nMolar mass: 40 g/mol\nState: Solid",
	"HCl": "Hydrochloric Acid\nMolar mass: 36.5 g/mol\nState: Liquid (solution)",
	"CO2": "Carbon Dioxide\nMolar mass: 44 g/mol\nState: Gas",
	"SO2": "Sulfur Dioxide\nMolar mass: 64 g/mol\nState: Gas",
	"H2CO3": "Carbonic Acid\nMolar mass: 62 g/mol\nState: Liquid (solution)",
	"H2SO3": "Sulfurous Acid\nMolar mass: 82 g/mol\nState: Liquid (solution)",
	"CaO": "Calcium Oxide\nCommon name: Quicklime\nMolar mass: 56 g/mol\nState: Solid",
	"Ca(OH)2": "Calcium Hydroxide\nMolar mass: 74 g/mol\nState: Solid",
	"NH3": "Ammonia\nMolar mass: 17 g/mol\nState: Gas",
	"NO": "Nitric Oxide\nMolar mass: 30 g/mol\nState: Gas",
	"NO2": "Nitrogen Dioxide\nMolar mass: 46 g/mol\nState: Gas",
	"HNO3": "Nitric Acid\nMolar mass: 63 g/mol\nState: Liquid",
	"H2S": "Hydrogen Sulfide\nMolar mass: 34 g/mol\nState: Gas",
	"Na2O": "Sodium Oxide\nMolar mass: 62 g/mol\nState: Solid",

	"NaSO3": "Sodium Sulfite\nState: Unknown"
}

func _ready():
	start_position = global_position
	original_z = z_index
	original_scale = scale

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	if dragging:
		return

	var tooltip = get_tree().get_first_node_in_group("reagent_tooltip")
	if tooltip and tooltip.has_method("show_tooltip"):
		tooltip.show_tooltip(reagent_description, get_global_mouse_position() + Vector2(24, 24))

func _on_mouse_exited() -> void:
	var tooltip = get_tree().get_first_node_in_group("reagent_tooltip")
	if tooltip and tooltip.has_method("hide_tooltip"):
		tooltip.hide_tooltip()

func _input_event(_viewport, event, _shape_idx):
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
			return

		var cat = get_tree().get_first_node_in_group("cat")
		if cat and cat.contains_point(mouse_pos):
			cat.react_to_reagent(reagent_id)
			reset_position()
			return

		reset_position()

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset

func reset_position():
	global_position = start_position

func setup(sprite_name: String):
	reagent_id = get_formula(sprite_name)
	reagent_description = reagent_descriptions.get(reagent_id, reagent_id)
	$Label.text = reagent_id
	$TextureRect.texture = load("res://assets/sprites/reagentsSprites/" + sprite_name + ".png")

func get_formula(name: String) -> String:
	name = name.to_lower()
	return map.get(name, name)
