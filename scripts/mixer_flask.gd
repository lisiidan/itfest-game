extends Area2D

@onready var contents_label = $ContentsLabel
@onready var reaction_system: Node2D = $"../ReactionSystem"
@onready var reagent_shelf: Node2D = $"../ReagentShelf"
@onready var goal_board: Node2D = $"../GoalBoard"

@onready var flask_visual = $FlaskSprite
@onready var liquid_half = $LiquidHalf
@onready var liquid_full = $LiquidFull
@onready var bubbles: GPUParticles2D = $Bubbles

@onready var feedback_label: Label = $"../UI/LabUI/FeedbackLabel"

var pending_shelf_reagents: Array[String] = []
var last_reaction_type: String = "neutral"

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

func get_full_name(name: String) -> String:
	return reverse_map.get(name, name)

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
		shake_flask()
		resolve_reaction()

	update_ui()

func split_products(result: String) -> Array[String]:
	var products: Array[String] = []

	for part in result.split("+"):
		var clean = part.strip_edges()
		if clean != "":
			products.append(clean)

	return products

func get_display_product(products: Array[String]) -> String:
	if products.is_empty():
		return ""
	return products[0]

func set_bubbles_color(color: Color):
	bubbles.modulate = color

func play_bubbles():
	if bubbles:
		bubbles.restart()
		bubbles.emitting = true

func resolve_reaction():
	if contents.size() != 2:
		return

	locked = true

	var a = contents[0]
	var b = contents[1]
	var reaction = reaction_system.check_reaction(a, b)
	last_reaction_type = reaction["type"]

	match reaction["type"]:
		"positive":
			var products = split_products(reaction["result"])
			pending_shelf_reagents = products

			var display_product = get_display_product(products)
			var result_color = get_reagent_color(display_product)

			contents = [display_product]
			show_single_reagent(display_product, true)
			set_bubbles_color(result_color)
			play_bubbles()
			flash_liquid(result_color)

			var discovered_any := false

			for product in products:
				goal_board.check_goal(product)
				if not reagent_shelf.reagent_already_spawned(product):
					discovered_any = true

			if discovered_any:
				show_feedback("New reagent discovered: " + ", ".join(products), Color(0.6, 1.0, 0.6))
			else:
				show_feedback("Already known reagent(s)", Color(1.0, 1.0, 0.0, 1.0))

		"bonus":
			var products = split_products(reaction["result"])
			pending_shelf_reagents = []

			var display_product = get_display_product(products)
			var result_color = get_reagent_color(display_product)

			contents = [display_product]
			show_single_reagent(display_product, true)
			set_bubbles_color(result_color)
			play_bubbles()
			flash_liquid(result_color)

			for product in products:
				goal_board.check_goal(product)

			show_feedback("New journal entry discovered", Color(0.6, 0.8, 1.0))

		"neutral":
			var mix_color = mix_colors(get_reagent_color(a), get_reagent_color(b))
			pending_shelf_reagents = []
			set_liquid_color(mix_color)
			set_bubbles_color(mix_color)
			play_bubbles()
			flash_liquid(mix_color)
			set_liquid_level(2)
			show_feedback("No observable reaction", Color(0.9, 0.9, 0.9))

func flash_liquid(color: Color):
	var original_modulate = liquid_half.modulate

	set_liquid_color(color.lightened(0.35))

	var tween = create_tween()
	tween.tween_interval(0.08)
	tween.tween_callback(func():
		set_liquid_color(original_modulate)
	)

func clear_flask():
	for reagent in pending_shelf_reagents:
		if not reagent_shelf.reagent_already_spawned(reagent) and not reagent_shelf.is_basic_reagent(get_full_name(reagent)):
			animate_result_to_shelf(reagent)

	pending_shelf_reagents.clear()

	contents.clear()
	locked = false
	last_reaction_type = "neutral"

	flask_visual.modulate = Color.WHITE
	hide_liquids()

	if feedback_label:
		feedback_label.visible = false

	update_ui()

func animate_result_to_shelf(reagent: String):
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/sprites/reagentsSprites/" + get_full_name(reagent) + ".png")
	sprite.global_position = global_position
	sprite.scale = Vector2(6, 6)
	sprite.centered = true

	get_tree().current_scene.add_child(sprite)

	var target_pos = reagent_shelf.get_next_slot_global_position()

	var tween = create_tween()
	tween.tween_property(sprite, "global_position", target_pos, 0.6)

	tween.tween_callback(func():
		sprite.queue_free()
		reagent_shelf.add_reagent_to_shelf(reagent)
	)

func update_ui():
	contents_label.text = "\n".join(contents)

func show_feedback(text: String, color: Color = Color.WHITE):
	if feedback_label == null:
		return

	feedback_label.text = text
	feedback_label.modulate = color
	feedback_label.visible = true

func show_single_reagent(id: String, full: bool):
	set_liquid_color(get_reagent_color(id))
	if full:
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

func shake_flask():
	var original_pos = position
	var tween = create_tween()

	tween.tween_property(self, "position", original_pos + Vector2(-6, 0), 0.04)
	tween.tween_property(self, "position", original_pos + Vector2(6, 0), 0.04)
	tween.tween_property(self, "position", original_pos + Vector2(-4, 0), 0.04)
	tween.tween_property(self, "position", original_pos + Vector2(4, 0), 0.04)
	tween.tween_property(self, "position", original_pos, 0.04)
