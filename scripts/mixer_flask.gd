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

@onready var explosion_shards: Sprite2D = $ExplosionShards
@onready var screen_flash: ColorRect = $"../UI/ScreenFlash"

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

func get_active_product(products: Array[String]) -> String:
	if products.is_empty():
		return ""
	return products[0]

func get_stored_products(products: Array[String]) -> Array[String]:
	if products.size() <= 1:
		return []

	var stored: Array[String] = []
	for i in range(1, products.size()):
		stored.append(products[i])

	return stored

func set_bubbles_color(color: Color):
	bubbles.modulate = color

func play_bubbles():
	if bubbles:
		bubbles.restart()
		bubbles.emitting = true

func is_explosive_pair(a: String, b: String) -> bool:
	return (a == "H2O" and b == "Na") or (a == "Na" and b == "H2O")

func trigger_explosion():
	locked = true
	pending_shelf_reagents.clear()
	last_reaction_type = "explosion"

	contents.clear()
	#contents.append("BOOM")
	update_ui()

	set_liquid_level(2)
	set_liquid_color(Color(1.0, 0.8, 0.2, 1.0))
	set_bubbles_color(Color(1.0, 0.8, 0.2, 1.0))
	play_bubbles()
	show_feedback("Explosion! The experiment failed.", Color.WHITE)

	var cat = get_tree().get_first_node_in_group("cat")
	if cat and cat.has_method("play_scared"):
		cat.play_scared()

	shake_big()
	await play_explosion_flash_sequence()

	var game = get_tree().get_first_node_in_group("game_controller")
	if game and game.has_method("fail_level"):
		game.fail_level()

func play_explosion_flash_sequence() -> void:
	if screen_flash:
		screen_flash.visible = true
		screen_flash.color = Color.WHITE
		screen_flash.modulate.a = 0.0

	# резкая вспышка
	var flash_in = create_tween()
	flash_in.tween_property(screen_flash, "modulate:a", 1.0, 0.06)
	await flash_in.finished

	# маленький hit stop
	get_tree().paused = true
	await get_tree().create_timer(0.06, true, false, true).timeout
	get_tree().paused = false

	# скрываем колбу, показываем осколки
	flask_visual.visible = false
	liquid_half.visible = false
	liquid_full.visible = false

	if explosion_shards:
		explosion_shards.visible = true
		explosion_shards.modulate = Color.WHITE

	# плавное прояснение
	var flash_out = create_tween()
	flash_out.tween_property(screen_flash, "modulate:a", 0.0, 0.45)
	await flash_out.finished

	if screen_flash:
		screen_flash.visible = false

func resolve_reaction():
	if contents.size() != 2:
		return

	locked = true

	var a = contents[0]
	var b = contents[1]

	if is_explosive_pair(a, b):
		trigger_explosion()
		return

	var reaction = reaction_system.check_reaction(a, b)
	last_reaction_type = reaction["type"]

	match reaction["type"]:
		"positive":
			var products = split_products(reaction["result"])
			pending_shelf_reagents = products.duplicate()

			var active_product = get_active_product(products)
			var stored_products = get_stored_products(products)
			var result_color = get_reagent_color(active_product)

			contents = [active_product]
			show_single_reagent(active_product, true)
			set_bubbles_color(result_color)
			play_bubbles()
			flash_liquid(result_color)

			var discovered_any := false
			for product in products:
				if not reagent_shelf.reagent_already_spawned(product):
					discovered_any = true

			if products.size() > 1:
				show_feedback(
					"Flask keeps " + active_product + " | Stored: " + ", ".join(stored_products),
					Color(0.344, 0.169, 0.078, 1.0)
				)
			elif discovered_any:
				show_feedback(
					"New reagent discovered: " + active_product,
					Color(0.344, 0.169, 0.078, 1.0)
				)
			else:
				show_feedback("Already known reagent(s)", Color(1.0, 1.0, 0.0, 1.0))

			locked = false

		"bonus":
			var products = split_products(reaction["result"])
			pending_shelf_reagents = []

			var active_product = get_active_product(products)
			var stored_products = get_stored_products(products)
			var result_color = get_reagent_color(active_product)

			contents = [active_product]
			show_single_reagent(active_product, true)
			set_bubbles_color(result_color)
			play_bubbles()
			flash_liquid(result_color)

			var unlocked_any := false
			for product in products:
				JournalManager.unlock_entry(product)
				unlocked_any = true

			if products.size() > 1:
				show_feedback(
					"Journal updated. Flask keeps " + active_product + " | Stored: " + ", ".join(stored_products),
					Color(0.6, 0.8, 1.0)
				)
			elif unlocked_any:
				show_feedback(
					"New journal entry discovered: " + active_product,
					Color(0.6, 0.8, 1.0)
				)
			else:
				show_feedback(
					"Journal updated",
					Color(0.6, 0.8, 1.0)
				)

			locked = false

		"neutral":
			var mix_color = mix_colors(get_reagent_color(a), get_reagent_color(b))
			pending_shelf_reagents.clear()
			set_liquid_color(mix_color)
			set_bubbles_color(mix_color)
			play_bubbles()
			flash_liquid(mix_color)
			set_liquid_level(2)
			show_feedback("No observable reaction, clear the flask", Color(0.9, 0.9, 0.9))
			# neutral stays locked until clear_flask()

func flash_liquid(color: Color):
	var original_modulate = liquid_half.modulate

	set_liquid_color(color.lightened(0.35))

	var tween = create_tween()
	tween.tween_interval(0.08)
	tween.tween_callback(func():
		set_liquid_color(original_modulate)
	)

func flash_explosion():
	flask_visual.modulate = Color(1.8, 1.5, 0.7, 1.0)
	liquid_half.modulate = Color(2.0, 1.4, 0.4, 1.0)
	liquid_full.modulate = Color(2.0, 1.4, 0.4, 1.0)

	var tween = create_tween()
	tween.tween_interval(0.12)
	tween.tween_callback(func():
		flask_visual.modulate = Color.WHITE
		set_liquid_color(Color(1.0, 0.72, 0.18, 1.0))
	)

func reset_flask():
	pending_shelf_reagents.clear()
	contents.clear()
	locked = false
	last_reaction_type = "neutral"

	hide_liquids()
	flask_visual.modulate = Color.WHITE

	if bubbles:
		bubbles.emitting = false

	if feedback_label:
		feedback_label.visible = false
	
	if explosion_shards:
		explosion_shards.visible = false

	if screen_flash:
		screen_flash.visible = false
		screen_flash.modulate.a = 0.0

	flask_visual.visible = true
	
	update_ui()

func clear_flask():
	if last_reaction_type == "explosion":
		return

	for reagent in pending_shelf_reagents:
		goal_board.check_goal(reagent)

		if not reagent_shelf.reagent_already_spawned(reagent) and not reagent_shelf.is_basic_reagent(get_full_name(reagent)):
			animate_result_to_shelf(reagent)

	pending_shelf_reagents.clear()

	contents.clear()
	locked = false
	last_reaction_type = "neutral"

	flask_visual.modulate = Color.WHITE
	hide_liquids()

	if bubbles:
		bubbles.emitting = false

	if feedback_label:
		feedback_label.visible = false

	update_ui()

func animate_result_to_shelf(reagent: String):
	var texture_path = "res://assets/sprites/reagentsSprites/" + get_full_name(reagent) + ".png"
	var texture = load(texture_path)

	if texture == null:
		reagent_shelf.add_reagent_to_shelf(reagent)
		JournalManager.unlock_entry(reagent)
		show_feedback("New journal entry unlocked: " + reagent, Color(0.344, 0.169, 0.078, 1.0))
		return

	var sprite := Sprite2D.new()
	sprite.texture = texture
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
		JournalManager.unlock_entry(reagent)
		show_feedback("New journal entry unlocked: " + reagent, Color(0.344, 0.169, 0.078, 1.0))
	)

func update_ui():
	contents_label.text = "\n".join(contents)

func show_feedback(text: String, color: Color = Color.WHITE):
	color = Color(0.344, 0.169, 0.078, 1.0)
	if feedback_label == null:
		return

	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)
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

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
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

func shake_big():
	var original_pos = position
	var tween = create_tween()

	tween.tween_property(self, "position", original_pos + Vector2(-10, 0), 0.03)
	tween.tween_property(self, "position", original_pos + Vector2(10, 0), 0.03)
	tween.tween_property(self, "position", original_pos + Vector2(-8, -4), 0.03)
	tween.tween_property(self, "position", original_pos + Vector2(8, 4), 0.03)
	tween.tween_property(self, "position", original_pos + Vector2(-6, 0), 0.03)
	tween.tween_property(self, "position", original_pos + Vector2(6, 0), 0.03)
	tween.tween_property(self, "position", original_pos, 0.03)
