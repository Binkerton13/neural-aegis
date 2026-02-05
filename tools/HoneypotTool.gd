extends Tool
## Honeypot Tool
## Deploys decoy resources to lure and identify threat actors

var dialog_scene = preload("res://scenes/HoneypotDialog.tscn")
var config_dialog: AcceptDialog = null

func _ready():
	super._ready()
	tool_name = "Honeypot"
	tool_description = "Deploy a decoy to attract and identify threats"
	real_world_equivalent = "Deception technology, honeypot deployment for threat intelligence"
	cooldown_time = 15.0
	resource_cost = 20

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
	var honeypot_name = ThemeManager.get_term("honeypot")
	var bait_name = config.get("bait", ThemeManager.get_term("honeypot_bait"))
	var location = config.get("location", "Unknown")
	var payload = config.get("payload", "Unknown")
	var threat_name = ThemeManager.get_term("threat_actor")
	
	var message = "Deployed " + honeypot_name + " at " + location
	message += " with " + bait_name + " (" + payload + ")"
	
	# Chance to attract threats based on payload quality
	var base_chance = 2
	if payload == "High Value Data":
		base_chance = 4
	elif payload == "Credentials":
		base_chance = 3
	
	var attracted_threats = randi() % base_chance + 1
	
	if attracted_threats > 0:
		message += ". Attracted " + str(attracted_threats) + " " + threat_name
		if attracted_threats > 1:
			message += "s"
		
		GameState.add_score(15 * attracted_threats)
		
		# Neutralize attracted threats
		for i in range(attracted_threats):
			GameState.neutralize_threat({
				"entity_id": randi() % 20 + 1,
				"method": "honeypot",
				"location": location,
				"bait": bait_name
			})
	
	# Update status with result
	var dashboard = get_tree().root.get_node_or_null("Main/MainDashboard")
	if dashboard:
		dashboard.update_status(message)
