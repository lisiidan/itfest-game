extends Control

@export var reagent_scene: PackedScene

func spawn_reagents(reagents: Array):
	var x := 0
	for r in reagents:
		var item = reagent_scene.instantiate()
		item.setup(r)
		item.position = Vector2(x, 0)
		add_child(item)
		x += 120
