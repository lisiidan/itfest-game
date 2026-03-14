extends Area2D

@onready var contents_label = $ContentsLabel
@onready var reaction_system: Node2D = $"../ReactionSystem"

@onready var flask_visual = $FlaskSprite
@onready var liquid_half = $LiquidHalf
@onready var liquid_full = $LiquidFull

@onready var feedback_label: Label = $"../UI/LabUI/FeedbackLabel"
@onready var feedback_timer: Timer = $FeedbackTimer

var contents: Array[String] = []
var locked := false

var reagent_data = {
	"H2": {"color": Color(0.551, 0.843, 0.898, 1.0)},
	"O2": {"color": Color(0.809, 0.173, 0.217, 1.0)},
	"N2": {"color": Color(0.420, 0.470, 0.900, 1.0)},
	"Cl2": {"color": Color(0.420, 0.900, 0.200, 1.0)},
	"C": {"color": Color(0.150, 0.150, 0.150, 1.0)},
	"Na": {"color": Color(0.450, 0.900, 0.200, 1.0)},
	"S": {"color": Color(0.950, 0.850, 0.200, 1.0)},
	"Ca": {"color": Color(0.882, 0.882, 0.882, 1.0)},

	"H2O": {"color": Color(0.250, 0.700, 0.950, 1.0)},
	"NaOH": {"color": Color(0.600, 0.950, 0.300, 1.0)},
	"HCl": {"color": Color(0.200, 0.950, 0.300, 1.0)},
	"NaCl": {"color": Color(0.920, 0.920, 0.920, 1.0)},
	"CO2": {"color": Color(0.450, 0.450, 0.450, 1.0)},
	"SO2": {"color": Color(0.950, 0.300, 0.200, 1.0)},
	"H2CO3": {"color": Color(0.850, 0.850, 0.850, 1.0)},
	"H2SO3": {"color": Color(0.950, 0.700, 0.200, 1.0)},
	"Ca(OH)2": {"color": Color(0.900, 0.900, 0.900, 1.0)},
	"CaO": {"color": Color(0.800, 0.800, 0.800, 1.0)},
	"NaSO3": {"color": Color(0.700, 0.700, 0.700, 1.0)},
	"NH3": {"color": Color(0.8, 0.224, 0.996, 1.0)},
	"NO": {"color": Color(0.300, 0.600, 0.950, 1.0)},
	"H2S": {"color": Color(0.500, 0.800, 0.200, 1.0)},
	"Na2O": {"color": Color(0.600, 0.950, 0.250, 1.0)},
	"NO2": {"color": Color(0.850, 0.200, 0.150, 1.0)},
	"HNO3": {"color": Color(0.950, 0.850, 0.200, 1.0)}
}

func _ready():
	add_to_group("mixer_flask")
	hide_liquids()

func contains_point(point: Vector2) -> bool:
	return $CollisionShape2D.shape.get_rect().has_point(to_local(point))

func add_reagent(id: String):
	print("ADD_REAGENT CALLED:", id)

	if locked or contents.size() >= 2:
		return

	contents.append(id)
	print("Flask:", contents)

	if contents.size() == 1:
		show_single_reagent(contents[0], false)
	else:
		show_mix_preview(contents[0], contents[1])
		resolve_reaction()

	update_ui()

func resolve_reaction():
	if contents.size() != 2:
		return

	locked = true

	var a = contents[0]
	var b = contents[1]
	var reaction = reaction_system.check_reaction(a, b)

	match reaction["type"]:
		"positive":
			contents = [reaction["result"]]
			show_single_reagent(reaction["result"], true)
			show_feedback("New reagent discovered: " + reaction["result"], Color(0.6, 1.0, 0.6))

		"bonus":
			contents = [reaction["result"]]
			show_single_reagent(reaction["result"], true)
			show_feedback("New journal entry discovered", Color(0.6, 0.8, 1.0))

		"neutral":
			set_liquid_color(Color(0.8, 0.8, 0.8, 1.0))
			set_liquid_level(2)
			show_feedback("No observable reaction", Color(0.9, 0.9, 0.9))

func clear_flask():
	contents.clear()
	locked = false
	flask_visual.modulate = Color.WHITE
	hide_liquids()

	if feedback_label:
		feedback_label.visible = false

	update_ui()

func update_ui():
	contents_label.text = "\n".join(contents)

func show_feedback(text: String, color: Color = Color.WHITE):
	if feedback_label == null:
		return

	feedback_label.text = text
	feedback_label.modulate = color
	feedback_label.visible = true
	feedback_timer.start()

func _on_feedback_timer_timeout():
	if feedback_label:
		feedback_label.visible = false

func show_single_reagent(id: String, full: bool):
	set_liquid_color(get_reagent_color(id))
	if(full):
		set_liquid_level(2)
	else:
		set_liquid_level(1)

func show_mix_preview(a_id: String, b_id: String):
	var a = get_reagent_color(a_id)
	var b = get_reagent_color(b_id)
	set_liquid_color(mix_colors(a, b))
	set_liquid_level(2)

func get_reagent_color(id: String) -> Color:
	if reagent_data.has(id):
		return reagent_data[id]["color"]
	return Color.WHITE

func mix_colors(a: Color, b: Color) -> Color:
	return Color(
		(a.r + b.r) * 0.5,
		(a.g + b.g) * 0.5,
		(a.b + b.b) * 0.5,
		1.0
	)

func set_liquid_color(color: Color):
	liquid_half.modulate = color
	liquid_full.modulate = color

func set_liquid_level(level: int):
	hide_liquids()

	if level == 1:
		liquid_half.visible = true
	elif level >= 2:
		liquid_full.visible = true

func hide_liquids():
	liquid_half.visible = false
	liquid_full.visible = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		clear_flask()
