extends Tool
## Isolation Forest Tool
## Identifies outlier behavior in entity activity using real sklearn anomaly detection

var pending_request: bool = false
var pending_entries: Array = []

func _ready():
	super._ready()
	tool_name = "Isolation Forest"
	tool_description = "Detect anomalous entities using real sklearn Isolation Forest"
	real_world_equivalent = "Anomaly detection in security logs, identifying compromised accounts"
	cooldown_time = 10.0
	resource_cost = 15
	
	# Connect to ML service responses
	MLClient.ml_response_received.connect(_on_ml_response)
	MLClient.ml_error.connect(_on_ml_error)

func use_tool(target_data: Dictionary) -> Dictionary:
	var base_result = super.use_tool(target_data)
	if not base_result.success:
		return base_result
	
	if not MLClient.is_available():
		return {
			"success": false,
			"message": "ML service not available. Please start the Python ML service."
		}
	
	# Check if we have target entries from drag-and-drop
	var target_entries = target_data.get("target_entries", [])
	
	if target_entries.size() > 0:
		return _analyze_selected_entries(target_entries)
	else:
		return _analyze_all_data()

func _analyze_selected_entries(entries: Array) -> Dictionary:
	# Extract entity values from selected entries
	var entity_values = []
	pending_entries = []
	
	for entry in entries:
		var entity_id = entry.get("entity_id", 0)
		if entity_id == 0 or entity_id == "":
			var message = entry.get("message", "")
			var regex = RegEx.new()
			regex.compile("#(\\d+)")
			var result = regex.search(message)
			if result:
				entity_id = result.get_string(1).to_int()
		
		if entity_id > 0:
			# Use entity_id as value (in real scenario, would extract actual metric)
			entity_values.append(float(entity_id))
			pending_entries.append(entry)
	
	if entity_values.size() < 3:
		return {
			"success": false,
			"message": "Need at least 3 entries for Isolation Forest analysis"
		}
	
	# Call real ML service
	pending_request = true
	MLClient.isolation_forest(entity_values, 0.2)  # Expect 20% outliers
	
	return {
		"success": true,
		"message": "Analyzing with sklearn Isolation Forest..."
	}

func _analyze_all_data() -> Dictionary:
	var entity_data = _get_entity_activity_data()
	var values = []
	
	for entity in entity_data:
		values.append(entity.get("value", 0.0))
	
	pending_request = true
	pending_entries = entity_data
	MLClient.isolation_forest(values, 0.1)
	
	return {
		"success": true,
		"message": "Analyzing all entities with sklearn Isolation Forest..."
	}

func _on_ml_response(endpoint: String, result: Dictionary):
	if not pending_request:
		return
	
	pending_request = false
	
	if result.has("outliers"):
		var outlier_indices = result.get("outliers", [])
		var scores = result.get("scores", [])
		
		var message = "sklearn Isolation Forest detected " + str(outlier_indices.size()) + " outlier(s)"
		
		if outlier_indices.size() > 0:
			message += ": "
			for i in range(min(3, outlier_indices.size())):
				if i > 0:
					message += ", "
				var idx = outlier_indices[i]
				if idx < pending_entries.size():
					var entry = pending_entries[idx]
					var entity_id = entry.get("id", entry.get("entity_id", idx))
					message += "#" + str(entity_id)
			
			GameState.add_score(15 * outlier_indices.size())
			
			# Show dialog to mark outliers
			_show_outlier_dialog(outlier_indices, scores)
		else:
			message += ". All entities within normal parameters."
			GameState.add_score(5)
		
		var dashboard = get_tree().root.get_node_or_null("Main/MainDashboard")
		if dashboard:
			dashboard.update_status(message)

func _on_ml_error(endpoint: String, error: String):
	if not pending_request:
		return
	
	pending_request = false
	print("ML Error: ", error)
	
	var dashboard = get_tree().root.get_node_or_null("Main/MainDashboard")
	if dashboard:
		dashboard.update_status("ML Error: " + error)

func _show_outlier_dialog(outlier_indices: Array, scores: Array):
	var dialog = ConfirmationDialog.new()
	dialog.title = "Mark Outliers as Alerts?"
	
	var vbox = VBoxContainer.new()
	var label = Label.new()
	label.text = "sklearn found " + str(outlier_indices.size()) + " outlier(s). Mark as alerts?"
	vbox.add_child(label)
	
	for i in range(outlier_indices.size()):
		var idx = outlier_indices[i]
		var score = scores[idx] if idx < scores.size() else 0.0
		
		var check = CheckBox.new()
		if idx < pending_entries.size():
			var entry = pending_entries[idx]
			var entity_id = entry.get("id", entry.get("entity_id", idx))
			check.text = "Entity #" + str(entity_id) + " (anomaly score: %.3f)" % score
		else:
			check.text = "Index " + str(idx) + " (anomaly score: %.3f)" % score
		check.button_pressed = true
		vbox.add_child(check)
	
	dialog.add_child(vbox)
	get_tree().root.add_child(dialog)
	
	dialog.confirmed.connect(func():
		var marked_count = 0
		var checkbox_idx = 0
		for child in vbox.get_children():
			if child is CheckBox and child.button_pressed:
				marked_count += 1
				if checkbox_idx < outlier_indices.size():
					var idx = outlier_indices[checkbox_idx]
					if idx < pending_entries.size():
						var entry = pending_entries[idx]
						var entity_id = entry.get("id", entry.get("entity_id", idx))
						GameState.detect_threat({
							"entity_id": entity_id,
							"type": "outlier",
							"method": "isolation_forest_sklearn"
						})
				checkbox_idx += 1
		
		var dashboard = get_tree().root.get_node_or_null("Main/MainDashboard")
		if dashboard:
			dashboard.update_status("Marked " + str(marked_count) + " outlier(s) as alerts")
		
		dialog.queue_free()
	)
	
	dialog.popup_centered()

func _get_entity_activity_data() -> Array:
	var data = []
	for i in range(20):
		var value = randf_range(15.0, 25.0)
		if i == 7 or i == 15:
			value = randf_range(45.0, 60.0)
		
		data.append({
			"id": i + 1,
			"value": value
		})
	return data
