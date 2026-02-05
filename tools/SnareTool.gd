extends Tool
## Snare Tool
## Sets automated traps for specific threat actor types

var dialog_scene = preload("res://scenes/SnareDialog.tscn")
var config_dialog: AcceptDialog = null

func _ready():
	super._ready()
	tool_name = "Snare"
	tool_description = "Set an automated trap to catch specific threats"
	real_world_equivalent = "IDS/IPS rule creation, automated threat response, SOAR playbooks"
	cooldown_time = 12.0
	resource_cost = 12

func use_tool(target_data: Dictionary) -> Dictionary:
	# Show configuration dialog instead of immediate execution
	show_config_dialog(target_data)
	return {"success": false, "message": "Configuration dialog opened"}

func show_config_dialog(target_data: Dictionary):
	if not config_dialog:
		config_dialog = dialog_scene.instantiate()
		get_tree().root.add_child(config_dialog)
		config_dialog.configuration_confirmed.connect(_on_config_confirmed.bind(target_data))
	
	config_dialog.show_dialog()

func _on_config_confirmed(config: Dictionary, target_data: Dictionary):
	var base_result = super.use_tool(target_data)
	if not base_result.success:
		return
	
	# Use the configuration from the dialog
	var snare_name = ThemeManager.get_term("defensive_action")
	var target = config.get("target", "Unknown")
	var location = config.get("location", "Unknown")
	var trigger = config.get("trigger", "Immediate")
	var threat_name = ThemeManager.get_term("threat_actor")
	
	var message = "Deployed " + snare_name + " at " + location
	message += " targeting " + target + " (trigger: " + trigger + ")"
	
	# Calculate effectiveness based on configuration
	var trigger_chance = 0.7  # Base 70% chance
	if trigger == "Immediate":
		trigger_chance = 0.9
	elif trigger == "On Access Attempt":
		trigger_chance = 0.8
	
	var triggered = randf() < trigger_chance
	
	if triggered:
		var caught_threats = randi() % 2 + 1
		if target == "All Threats":
			caught_threats += 1
		
		message += ". Caught " + str(caught_threats) + " " + threat_name
		if caught_threats > 1:
			message += "s"
		message += "!"
		
		GameState.add_score(12 * caught_threats)
		
		# Neutralize caught threats
		for i in range(caught_threats):
			GameState.neutralize_threat({
				"entity_id": randi() % 20 + 1,
				"method": "snare",
				"trap_type": snare_name,
				"location": location
			})
	else:
		message += ". No threats caught yet (monitoring...)"
		GameState.add_score(2)
	
	# Update status with result
	var dashboard = get_tree().root.get_node_or_null("Main/MainDashboard")
	if dashboard:
		dashboard.update_status(message)
