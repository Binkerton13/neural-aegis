extends Control
## Main dashboard controller
## Manages the primary game interface including log viewer, tool palette, and UI updates

@onready var log_viewer = $MainLayout/ContentArea/LogViewer
@onready var tool_palette = $MainLayout/ContentArea/ToolPalette
@onready var visualization_panel = $MainLayout/ContentArea/VisualizationPanel
@onready var score_label = $MainLayout/TopBar/TopBarLayout/StatsPanel/ScoreLabel
@onready var threats_label = $MainLayout/TopBar/TopBarLayout/StatsPanel/ThreatsLabel
@onready var resources_label = $MainLayout/TopBar/TopBarLayout/StatsPanel/ResourcesLabel
@onready var theme_selector = $MainLayout/TopBar/TopBarLayout/ThemePanel/ThemeSelector
@onready var status_label = $MainLayout/BottomBar/StatusLabel

var log_generator: Node

func _ready():
	setup_log_generator()
	setup_theme_selector()
	connect_signals()
	update_ui()

func setup_log_generator():
	log_generator = preload("res://scripts/LogGenerator.gd").new()
	add_child(log_generator)
	log_generator.log_entry_generated.connect(_on_log_entry_generated)

func setup_theme_selector():
	if theme_selector:
		theme_selector.clear()
		for theme_key in ThemeManager.get_available_themes():
			var display_name = ThemeManager.get_theme_display_name(theme_key)
			theme_selector.add_item(display_name)
			theme_selector.set_item_metadata(theme_selector.get_item_count() - 1, theme_key)
		
		# Select current theme
		for i in range(theme_selector.get_item_count()):
			if theme_selector.get_item_metadata(i) == ThemeManager.current_theme:
				theme_selector.select(i)
				break

func connect_signals():
	GameState.score_changed.connect(_on_score_changed)
	GameState.resource_changed.connect(_on_resources_changed)
	GameState.threat_detected.connect(_on_threat_detected)
	GameState.threat_neutralized.connect(_on_threat_neutralized)
	GameState.tool_used.connect(_on_tool_used)
	ThemeManager.theme_changed.connect(_on_theme_changed)
	
	if theme_selector:
		theme_selector.item_selected.connect(_on_theme_selected)
	
	# Connect tool buttons
	if tool_palette:
		for child in tool_palette.get_children():
			if child is Button and child.has_method("use_tool"):
				child.pressed.connect(_on_tool_button_pressed.bind(child))

func _on_log_entry_generated(entry: Dictionary):
	if log_viewer:
		log_viewer.add_log_entry(entry)
	
	# Update visualization panel with log events
	if visualization_panel:
		visualization_panel.process_log_event(entry)

func _on_score_changed(new_score: int):
	if score_label:
		score_label.text = "Score: " + str(new_score)

func _on_resources_changed(new_resources: int):
	if resources_label:
		resources_label.text = "Resources: " + str(new_resources) + "%"

func _on_threat_detected(threat_data: Dictionary):
	if threats_label:
		threats_label.text = "Threats Detected: " + str(GameState.threats_detected)
	update_status("Threat detected! Entity #" + str(threat_data.get("entity_id", "?")))
	
	# Highlight in visualization
	if visualization_panel:
		var entity_id = threat_data.get("entity_id", 0)
		if entity_id > 0:
			visualization_panel.mark_as_alert(entity_id)

func _on_threat_neutralized(threat_data: Dictionary):
	update_status("Threat neutralized! +10 score")
	
	# Animate neutralization in visualization
	if visualization_panel:
		var entity_id = threat_data.get("entity_id", 0)
		if entity_id > 0:
			visualization_panel.animate_threat_neutralized(entity_id)

func _on_tool_used(tool_name: String, _target_data: Dictionary):
	update_status("Tool used: " + tool_name)

func _on_theme_changed(_new_theme: String):
	update_status("Theme changed to: " + ThemeManager.get_current_theme_name())
	# Refresh log viewer to show new theme terms
	if log_viewer:
		log_viewer.clear_logs()

func _on_theme_selected(index: int):
	if theme_selector:
		var theme_key = theme_selector.get_item_metadata(index)
		ThemeManager.switch_theme(theme_key)

func _on_tool_button_pressed(tool: Tool):
	if tool and tool.can_use:
		var result = tool.use_tool({})
		if result.success:
			update_status(result.message)
		else:
			update_status("Tool failed: " + result.message)

func update_ui():
	_on_score_changed(GameState.score)
	_on_resources_changed(GameState.resources)
	if threats_label:
		threats_label.text = "Threats Detected: " + str(GameState.threats_detected)

func update_status(message: String):
	if status_label:
		status_label.text = "Status: " + message
	print("Status: ", message)
