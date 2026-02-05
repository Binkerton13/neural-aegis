extends Tool
## Trace Tool
## Tracks communication patterns and connections between entities

func _ready():
	super._ready()
	tool_name = "Trace"
	tool_description = "Track communication patterns and entity connections"
	real_world_equivalent = "Network traffic analysis, packet tracing, connection mapping"
	cooldown_time = 6.0
	resource_cost = 8

func use_tool(target_data: Dictionary) -> Dictionary:
	var base_result = super.use_tool(target_data)
	if not base_result.success:
		return base_result
	
	# Simulate trace operation
	var trace_action = ThemeManager.get_term("trace_action")
	var threat_name = ThemeManager.get_term("threat_actor")
	
	var source_id = randi() % 20 + 1
	var target_id = randi() % 20 + 1
	var connection_count = randi() % 5 + 1
	
	var message = trace_action.capitalize() + " revealed " + str(connection_count)
	message += " connections from " + threat_name + " #" + str(source_id)
	message += " to entity #" + str(target_id)
	
	# Check if this reveals a threat
	if connection_count >= 3:
		message += " (SUSPICIOUS PATTERN)"
		GameState.detect_threat({
			"entity_id": source_id,
			"type": "suspicious_communication",
			"target": target_id
		})
		GameState.add_score(8)
	else:
		GameState.add_score(3)
	
	return {
		"success": true,
		"message": message,
		"source": source_id,
		"target": target_id,
		"connections": connection_count
	}
