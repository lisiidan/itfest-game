extends Node

var reactions = {
	["Water","Salt"]: {
		"type": "positive",
		"result": "Saline Solution"
	},
	["Hydrogen","Chlorine"]: {
		"type": "catastrophic",
		"result": ""
	}
}

func check_reaction(contents: Array):
	if contents.size() < 2:
		return null

	var a = contents[-2]
	var b = contents[-1]

	var key = [a,b]
	var key_rev = [b,a]

	if reactions.has(key):
		return reactions[key]

	if reactions.has(key_rev):
		return reactions[key_rev]

	return {
		"type": "neutral",
		"result": ""
	}
