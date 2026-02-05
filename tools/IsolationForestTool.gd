extends Tool
## Isolation Forest Tool
## Identifies outlier behavior in entity activity using anomaly detection

func _ready():
	super._ready()
	tool_name = "Isolation Forest"
	tool_description = "Detect anomalous entities using ML-based outlier detection"
	real_world_equivalent = "Anomaly detection in security logs, identifying compromised accounts"
	cooldown_time = 10.0
	resource_cost = 15

func use_tool(target_data: Dictionary) -> Dictionary:
	var base_result = super.use_tool(target_data)
	if not base_result.success:
		return base_result
	
	# Simulate outlier detection
	var entity_data = _get_entity_activity_data()
	var detector = AnomalyDetector.new()
	var outliers = detector.identify_outliers(entity_data)
	
	if outliers.size() > 0:
		var message = "Detected " + str(outliers.size()) + " anomalous "
		message += ThemeManager.get_term("normal_entity_plural") + ": "
		
		for i in range(min(3, outliers.size())):
			if i > 0:
				message += ", "
			message += "#" + str(outliers[i].entity.get("id", "?"))
		
		GameState.add_score(10)
		
		# Mark threats for potential neutralization
		for outlier in outliers:
			if randf() > 0.5:  # 50% chance to neutralize
				GameState.neutralize_threat({
					"entity_id": outlier.entity.get("id", -1),
					"method": "isolation_forest"
				})
		
		return {
			"success": true,
			"message": message,
			"outliers": outliers
		}
	else:
		return {
			"success": true,
			"message": "No anomalies detected. All entities within normal parameters.",
			"outliers": []
		}

## Get simulated entity activity data
func _get_entity_activity_data() -> Array:
	var data = []
	for i in range(20):
		var value = randf_range(15.0, 25.0)
		# Add some outliers
		if i == 7 or i == 15:
			value = randf_range(45.0, 60.0)
		
		data.append({
			"id": i + 1,
			"value": value
		})
	return data
