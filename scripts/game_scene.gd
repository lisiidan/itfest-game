extends Node2D

@onready var reagent_shelf: Control = $UI/LabUI/ReagentShelf

var level_data = {
	"goal": "CO2",
	"reagents": ["Water", "Salt", "Hydrogen", "Chlorine"]
}

func _ready():
	reagent_shelf.spawn_reagents(level_data["reagents"])
