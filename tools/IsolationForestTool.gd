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
	
	# Check if we have target entries from drag-and-drop
	var target_entries = target_data.get("target_entries", [])
	
	if target_entries.size() > 0:
		# Analyze the selected log entries
		return _analyze_selected_entries(target_entries)
	else:
		# Simulate outlier detection on all data
		return _analyze_all_data()

func _analyze_selected_entries(entries: Array) -> Dictionary:
	# Extract entity values from selected entries
	var entity_values = []
	for entry in entries:
		var entity_id = entry.get("entity_id", 0)
		# Parse entity ID from message if not directly available
		if entity_id == 0 or entity_id == "":
			var message = entry.get("message", "")
			# Try to extract entity ID from message (e.g., "Entity #5")
			var regex = RegEx.new()
			regex.compile("#(\\d+)")
			var result = regex.search(message)
			if result:
				entity_id = result.get_string(1).to_int()
		
		if entity_id > 0:
			entity_values.append({
				"id": entity_id,
				"value": randf_range(15.0, 60.0),  # Simulated value
				"entry": entry
			})
	
	if entity_values.size() == 0:
		return {
			"success": true,
			"message": "No valid entities found in selection",
			"outliers": []
		}
	
	# Perform outlier detection on selected entries
	var detector = AnomalyDetector.new()
	var outliers = detector.identify_outliers(entity_values)
	
	var message = "Analyzed " + str(entity_values.size()) + " selected entries. "
	
	if outliers.size() > 0:
		message += "Found " + str(outliers.size()) + " outlier(s): "
		for i in range(min(3, outliers.size())):
			if i > 0:
				message += ", "
			message += "#" + str(outliers[i].entity.get("id", "?"))
		
		GameState.add_score(15 * outliers.size())
		
		# Show confirmation dialog for marking alerts
		_show_outlier_dialog(outliers)
	else:
		message += "No outliers detected in selection."
		GameState.add_score(5)
	
	return {
		"success": true,
		"message": message,
		"outliers": outliers
	}

func _analyze_all_data() -> Dictionary:
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

func _show_outlier_dialog(outliers: Array):
	# Create a simple confirmation dialog for marking outliers as alerts
	var dialog = ConfirmationDialog.new()
	dialog.title = "Mark Outliers as Alerts?"
	
	var vbox = VBoxContainer.new()
	var label = Label.new()
	label.text = "Found " + str(outliers.size()) + " outlier(s). Mark as alerts?"
	vbox.add_child(label)
	
	for outlier in outliers:
		var check = CheckBox.new()
		check.text = "Entity #" + str(outlier.entity.get("id", "?")) + " (z-score: " + str("%.2f" % outlier.z_score) + ")"
		check.button_pressed = true
		vbox.add_child(check)
	
	dialog.add_child(vbox)
	get_tree().root.add_child(dialog)
	
	dialog.confirmed.connect(func():
		var marked_count = 0
		for child in vbox.get_children():
			if child is CheckBox and child.button_pressed:
				marked_count += 1
				# Extract entity ID and mark as threat
				var text = child.text
				var regex = RegEx.new()
				regex.compile("#(\\d+)")
				var result = regex.search(text)
				if result:
					var entity_id = result.get_string(1).to_int()
					GameState.detect_threat({
						"entity_id": entity_id,
						"type": "outlier",
						"method": "user_marked"
					})
		
		var dashboard = get_tree().root.get_node_or_null("Main/MainDashboard")
		if dashboard:
			dashboard.update_status("Marked " + str(marked_count) + " outlier(s) as alerts")
		
		dialog.queue_free()
	)
	
	dialog.popup_centered()

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
