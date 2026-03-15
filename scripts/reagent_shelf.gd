extends Node2D

@export var reagent_scene: PackedScene

const PER_ROW := 6
const MAX_REAGENTS := 24
const CELL_W := 130
const CELL_H := 155

var reverse_map = {
	"H2": "hydrogen",
	"O2": "oxygen",
	"N2": "nitrogen",
	"Cl2": "chlorine",
	"C": "carbon",
	"Na": "sodium",
	"S": "sulfur",
	"Ca": "calcium",

	"H2O": "water",
	"NaOH": "sodium_hydroxide",
	"HCl": "hydrochloric_acid",
	"NaCl": "sodium_chloride",
	"CO2": "carbon_dioxide",
	"SO2": "sulfur_dioxide",
	"H2CO3": "carbonic_acid",
	"H2SO3": "sulfurous_acid",
	"Ca(OH)2": "calcium_hydroxide",
	"CaO": "calcium_oxide",
	"NaSO3": "sodium_sulfite",
	"NH3": "ammonia",
	"NO": "nitric_oxide",
	"H2S": "hydrogen_sulfide",
	"Na2O": "sodium_oxide",
	"NO2": "nitrogen_dioxide",
	"HNO3": "nitric_acid"
}

var spawned_reagents: Array[String] = []
var basic_reagents: Array[String] = [
	"hydrogen", "oxygen", "nitrogen", 
	"chlorine", "carbon", "sodium", 
	"sulfur", "calcium"
]

func clear_shelf():
	spawned_reagents.clear()

	for child in get_children():
		child.queue_free()

func spawn_reagents(reagents: Array):
	for r in reagents:
		add_reagent_to_shelf(r)

func reagent_already_spawned(reagent_name: String) -> bool:
	return spawned_reagents.has(reagent_name)

func is_basic_reagent(reagent_name: String) -> bool:
	return basic_reagents.has(reagent_name)

func add_reagent_to_shelf(reagent_name: String):
	if reagent_already_spawned(reagent_name):
		return

	if spawned_reagents.size() >= MAX_REAGENTS:
		return
	
	var i = spawned_reagents.size()
	spawned_reagents.append(reagent_name)

	var item = reagent_scene.instantiate()
	item.setup(get_full_name(reagent_name))

	var row = i / PER_ROW
	var col = i % PER_ROW
	item.position = Vector2(col * CELL_W, row * CELL_H)

	add_child(item)

func get_full_name(name: String) -> String:
	return reverse_map.get(name, name)

func get_next_slot_global_position() -> Vector2:
	var i = spawned_reagents.size()

	if i >= MAX_REAGENTS:
		return global_position

	var row = i / PER_ROW
	var col = i % PER_ROW

	var local_pos = Vector2(
		col * CELL_W + CELL_W * 0.5,
		row * CELL_H + CELL_H * 0.5
	)

	return to_global(local_pos)
