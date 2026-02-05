extends Tool
## Honeypot Tool
## Deploys decoy resources to lure and identify threat actors

func _ready():
	super._ready()
	tool_name = "Honeypot"
	tool_description = "Deploy a decoy to attract and identify threats"
	real_world_equivalent = "Deception technology, honeypot deployment for threat intelligence"
	cooldown_time = 15.0
	resource_cost = 20

func use_tool(target_data: Dictionary) -> Dictionary:
	var base_result = super.use_tool(target_data)
	if not base_result.success:
		return base_result
	
	# Simulate honeypot deployment
	var honeypot_name = ThemeManager.get_term("honeypot")
	var bait_name = ThemeManager.get_term("honeypot_bait")
	var threat_name = ThemeManager.get_term("threat_actor")
	
	var message = "Deployed " + honeypot_name + " with " + bait_name
	
	# Chance to attract threats
	var attracted_threats = randi() % 3 + 1
	
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
				"location": honeypot_name
			})
	
	return {
		"success": true,
		"message": message,
		"threats_caught": attracted_threats
	}
