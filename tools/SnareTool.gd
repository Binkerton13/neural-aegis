extends Tool
## Snare Tool
## Sets automated traps for specific threat actor types

func _ready():
	super._ready()
	tool_name = "Snare"
	tool_description = "Set an automated trap to catch specific threats"
	real_world_equivalent = "IDS/IPS rule creation, automated threat response, SOAR playbooks"
	cooldown_time = 12.0
	resource_cost = 12

func use_tool(target_data: Dictionary) -> Dictionary:
	var base_result = super.use_tool(target_data)
	if not base_result.success:
		return base_result
	
	# Simulate snare deployment
	var snare_name = ThemeManager.get_term("defensive_action")
	var threat_name = ThemeManager.get_term("threat_actor")
	
	var message = "Deployed " + snare_name + " targeting " + threat_name + "s"
	
	# Simulate trap triggering
	var triggered = randf() > 0.3  # 70% chance to trigger
	
	if triggered:
		var caught_threats = randi() % 2 + 1
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
				"trap_type": snare_name
			})
	else:
		message += ". No threats caught yet (monitoring...)"
		GameState.add_score(2)
	
	return {
		"success": true,
		"message": message,
		"triggered": triggered
	}
