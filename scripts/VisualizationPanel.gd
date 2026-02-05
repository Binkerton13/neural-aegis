extends Control
## Visualization panel showing an overhead view with interactive shapes
## Displays entities and their activities as simple geometric shapes

@onready var viewport_container: SubViewportContainer = $VBoxContainer/SubViewportContainer
@onready var viewport: SubViewport = $VBoxContainer/SubViewportContainer/SubViewport
@onready var canvas: Control = $VBoxContainer/SubViewportContainer/SubViewport/Canvas

# Entity shapes
var entities: Dictionary = {}  # entity_id -> EntityShape
var entity_colors = {
	"normal": Color(0.3, 0.7, 0.3),      # Green for normal entities
	"threat": Color(0.9, 0.3, 0.3),       # Red for threats
	"secondary": Color(0.9, 0.6, 0.2),    # Orange for secondary threats
	"honeypot": Color(1.0, 0.8, 0.2),     # Yellow for honeypots
	"snare": Color(0.5, 0.5, 0.9)         # Blue for snares
}

var dragging_entity = null
var drag_offset: Vector2 = Vector2.ZERO

class EntityShape:
	var id: int
	var type: String
	var position: Vector2
	var velocity: Vector2
	var shape_node: Control
	var label: Label
	var is_alert: bool = false
	
	func _init(entity_id: int, entity_type: String, pos: Vector2):
		id = entity_id
		type = entity_type
		position = pos
		velocity = Vector2.ZERO

func _ready():
	setup_canvas()
	generate_initial_entities()

func setup_canvas():
	if not canvas:
		canvas = Control.new()
		canvas.name = "Canvas"
		canvas.mouse_filter = Control.MOUSE_FILTER_PASS
		if viewport:
			viewport.add_child(canvas)
	
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func generate_initial_entities():
	# Generate some initial normal entities
	for i in range(15):
		var pos = Vector2(
			randf_range(50, canvas.size.x - 50) if canvas.size.x > 100 else randf_range(50, 750),
			randf_range(50, canvas.size.y - 50) if canvas.size.y > 100 else randf_range(50, 550)
		)
		create_entity(i + 1, "normal", pos)
	
	# Generate a few threat entities
	for i in range(3):
		var pos = Vector2(
			randf_range(50, canvas.size.x - 50) if canvas.size.x > 100 else randf_range(50, 750),
			randf_range(50, canvas.size.y - 50) if canvas.size.y > 100 else randf_range(50, 550)
		)
		create_entity(100 + i, "threat", pos)

func create_entity(entity_id: int, entity_type: String, pos: Vector2) -> EntityShape:
	var entity = EntityShape.new(entity_id, entity_type, pos)
	
	# Create visual representation
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(40, 40)
	panel.position = pos - Vector2(20, 20)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Create shape based on type
	var shape = Control.new()
	shape.custom_minimum_size = Vector2(40, 40)
	
	# Add background color
	var style = StyleBoxFlat.new()
	style.bg_color = entity_colors.get(entity_type, Color.GRAY)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	if entity_type == "threat":
		# Make threats more angular
		style.corner_radius_top_left = 0
		style.corner_radius_top_right = 0
		style.corner_radius_bottom_left = 0
		style.corner_radius_bottom_right = 0
	panel.add_theme_stylebox_override("panel", style)
	
	# Add label
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	var label = Label.new()
	label.text = str(entity_id)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(label)
	
	entity.shape_node = panel
	entity.label = label
	
	# Connect input events
	panel.gui_input.connect(_on_entity_input.bind(entity))
	
	if canvas:
		canvas.add_child(panel)
	
	entities[entity_id] = entity
	return entity

func _on_entity_input(event: InputEvent, entity: EntityShape):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				dragging_entity = entity
				drag_offset = entity.shape_node.position - event.position
			else:
				# Stop dragging
				dragging_entity = null
	elif event is InputEventMouseMotion:
		if dragging_entity == entity and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			# Update position while dragging
			var new_pos = event.position + drag_offset
			entity.shape_node.position = new_pos
			entity.position = new_pos + Vector2(20, 20)

func _process(delta):
	# Animate entities with simple movement
	for entity in entities.values():
		if entity != dragging_entity:
			# Apply simple wandering movement
			if entity.velocity.length() < 10:
				entity.velocity = Vector2(
					randf_range(-20, 20),
					randf_range(-20, 20)
				)
			
			entity.velocity *= 0.98  # Damping
			entity.position += entity.velocity * delta
			
			# Bounce off edges
			var canvas_size = canvas.size if canvas.size.x > 0 else Vector2(800, 600)
			if entity.position.x < 20:
				entity.position.x = 20
				entity.velocity.x = abs(entity.velocity.x)
			elif entity.position.x > canvas_size.x - 20:
				entity.position.x = canvas_size.x - 20
				entity.velocity.x = -abs(entity.velocity.x)
			
			if entity.position.y < 20:
				entity.position.y = 20
				entity.velocity.y = abs(entity.velocity.y)
			elif entity.position.y > canvas_size.y - 20:
				entity.position.y = canvas_size.y - 20
				entity.velocity.y = -abs(entity.velocity.y)
			
			# Update visual position
			if entity.shape_node:
				entity.shape_node.position = entity.position - Vector2(20, 20)

func highlight_entity(entity_id: int, color: Color = Color.YELLOW):
	if entities.has(entity_id):
		var entity = entities[entity_id]
		if entity.shape_node:
			var style = StyleBoxFlat.new()
			style.bg_color = color
			style.border_color = Color.WHITE
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.corner_radius_top_left = 5
			style.corner_radius_top_right = 5
			style.corner_radius_bottom_left = 5
			style.corner_radius_bottom_right = 5
			entity.shape_node.add_theme_stylebox_override("panel", style)

func mark_as_alert(entity_id: int):
	if entities.has(entity_id):
		var entity = entities[entity_id]
		entity.is_alert = true
		highlight_entity(entity_id, Color.RED)

func add_honeypot(location: String):
	var pos = Vector2(
		randf_range(100, canvas.size.x - 100) if canvas.size.x > 200 else randf_range(100, 700),
		randf_range(100, canvas.size.y - 100) if canvas.size.y > 200 else randf_range(100, 500)
	)
	var honeypot_id = 500 + entities.size()
	create_entity(honeypot_id, "honeypot", pos)

func add_snare(location: String):
	var pos = Vector2(
		randf_range(100, canvas.size.x - 100) if canvas.size.x > 200 else randf_range(100, 700),
		randf_range(100, canvas.size.y - 100) if canvas.size.y > 200 else randf_range(100, 500)
	)
	var snare_id = 600 + entities.size()
	var snare = create_entity(snare_id, "snare", pos)
	
	# Make snare stationary
	snare.velocity = Vector2.ZERO

func show_connection(from_id: int, to_id: int):
	if entities.has(from_id) and entities.has(to_id):
		var from_entity = entities[from_id]
		var to_entity = entities[to_id]
		
		# Create a line between entities (will be drawn in _draw)
		queue_redraw()

func animate_threat_neutralized(entity_id: int):
	if entities.has(entity_id):
		var entity = entities[entity_id]
		
		# Create fade out animation
		var tween = create_tween()
		if entity.shape_node:
			tween.tween_property(entity.shape_node, "modulate:a", 0.0, 0.5)
			tween.tween_callback(func():
				if entity.shape_node:
					entity.shape_node.queue_free()
				entities.erase(entity_id)
			)

func process_log_event(entry: Dictionary):
	var entity_id = entry.get("entity_id", 0)
	var level = entry.get("level", "INFO")
	var message = entry.get("message", "")
	
	# Extract entity ID from message if not directly available
	# Note: entity_id can be int, String, or missing depending on the log source
	# Check for invalid/empty values: null, 0 (invalid ID), or empty strings
	if entity_id == null or entity_id == 0 or (typeof(entity_id) == TYPE_STRING and entity_id.is_empty()):
		var regex = RegEx.new()
		regex.compile("#(\\d+)")
		var result = regex.search(message)
		if result:
			entity_id = result.get_string(1).to_int()
	
	if entity_id > 0:
		# Highlight entity based on log level
		if level == "ALERT":
			mark_as_alert(entity_id)
		elif level == "WARN":
			highlight_entity(entity_id, Color.ORANGE)
