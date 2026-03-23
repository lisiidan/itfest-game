extends Node

signal entry_unlocked(entry_id: String)

var unlocked_entries: Array[String] = []

var default_entries: Array[String] = [
	"H2", "O2", "N2", "Cl2",
	"C", "Na", "S", "Ca"
]

func _ready():
	reset_to_default()

func reset_to_default():
	unlocked_entries = default_entries.duplicate()

func unlock_entry(entry_id: String):
	if entry_id == "":
		return false

	if unlocked_entries.has(entry_id):
		return false

	unlocked_entries.append(entry_id)
	entry_unlocked.emit(entry_id)
	return true

func is_unlocked(entry_id: String) -> bool:
	return unlocked_entries.has(entry_id)

func get_unlocked_entries() -> Array[String]:
	return unlocked_entries.duplicate()
