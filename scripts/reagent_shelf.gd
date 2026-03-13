extends Control

@export var reagent_scene: PackedScene

const PER_ROW := 5
const MAX_REAGENTS := 15
const CELL_W := 120
const CELL_H := 120

func spawn_reagents(reagents: Array):
	for i in min(reagents.size(), MAX_REAGENTS):
		var r = reagents[i]
		var item = reagent_scene.instantiate()
		item.setup(r)

		var row = i / PER_ROW
		var col = i % PER_ROW

		item.position = Vector2(col * CELL_W, row * CELL_H)

		add_child(item)
