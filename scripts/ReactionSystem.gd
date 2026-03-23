extends Node

var reactions: Dictionary = {}

func _ready():
	reactions = load_reactions_from_csv("res://assets/resources/reactii_final.txt")

func load_reactions_from_csv(path: String) -> Dictionary:
	var result: Dictionary = {}

	print(FileAccess.file_exists("res://assets/resources/reactii_final.txt"))
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open file: " + path)
		return result

	var lines: Array[String] = []
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line != "":
			lines.append(line)

	if lines.size() < 2:
		push_error("CSV must contain header and at least one row")
		return result

	var header: Array[String] = []
	for cell in lines[0].split(";"):
		header.append(cell.strip_edges())

	for row_index in range(1, lines.size()):
		var cols_raw = lines[row_index].split(";")
		var cols: Array[String] = []
		for cell in cols_raw:
			cols.append(cell.strip_edges())

		if cols.is_empty():
			continue

		var row_reagent := cols[0]
		if row_reagent == "":
			continue

		for col_index in range(1, min(cols.size(), header.size())):
			var cell := cols[col_index]

			if cell == "" or cell == "-":
				continue

			var col_reagent := header[col_index]
			if col_reagent == "":
				continue

			var parsed = parse_cell(cell)

			result[row_reagent + "|" + col_reagent] = parsed
			result[col_reagent + "|" + row_reagent] = parsed

	return result

func parse_cell(cell: String) -> Dictionary:
	if cell.begins_with("p:"):
		return {
			"type": "positive",
			"result": cell.substr(2).strip_edges()
		}

	if cell.begins_with("b:"):
		return {
			"type": "bonus",
			"result": cell.substr(2).strip_edges()
		}

	return {
		"type": "neutral",
		"result": ""
	}

func check_reaction(a: String, b: String) -> Dictionary:
	return reactions.get(a + "|" + b, {
		"type": "neutral",
		"result": ""
	})
