extends Node2D

@export var reagent_scene: PackedScene

const PER_ROW := 6
const MAX_REAGENTS := 24
const CELL_W := 130
const CELL_H := 155

func spawn_reagents(reagents: Array):
	for i in min(reagents.size(), MAX_REAGENTS):
		var r = reagents[i]
		var item = reagent_scene.instantiate()
		item.setup(r)

		var row = i / PER_ROW
		var col = i % PER_ROW

		item.position = Vector2(col * CELL_W, row * CELL_H)

		add_child(item)
