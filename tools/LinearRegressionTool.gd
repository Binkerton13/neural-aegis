extends Tool
## Linear Regression Tool
## Analyzes resource collection patterns and predicts future trends using real sklearn

var pending_request: bool = false

func _ready():
	super._ready()
	tool_name = "Linear Regression"
	tool_description = "Analyze trends and predict future behavior patterns using real ML"
	real_world_equivalent = "Time-series forecasting, trend analysis for capacity planning"
	cooldown_time = 8.0
	resource_cost = 10
	
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
	
	# Get historical data
	var target_entries = target_data.get("target_entries", [])
	var historical_data = []
	
	if target_entries.size() > 0:
		# Extract values from selected log entries
		for entry in target_entries:
			var entity_id = entry.get("entity_id", 0)
			if entity_id > 0:
				# Use entity_id as a proxy value (in real scenario, would extract actual metric)
				historical_data.append(float(entity_id))
	else:
		# Use simulated historical data if no selection
		historical_data = _get_historical_data()
	
	if historical_data.size() < 3:
		return {
			"success": false,
			"message": "Insufficient data for trend analysis (need at least 3 points)"
		}
	
	# Call real ML service
	pending_request = true
	MLClient.linear_regression(historical_data, 5)
	
	return {
		"success": true,
		"message": "Analyzing trend with sklearn Linear Regression..."
	}

func _on_ml_response(endpoint: String, result: Dictionary):
	if not pending_request:
		return
	
	pending_request = false
	
	if result.has("predictions"):
		var trend = result.get("trend", "unknown")
		var slope = result.get("slope", 0.0)
		var r_squared = result.get("r_squared", 0.0)
		var predictions = result.get("predictions", [])
		
		var message = "Trend Analysis (sklearn): Pattern is " + trend
		message += " (slope: %.2f, R²: %.2f)" % [slope, r_squared]
		message += "\nNext predictions: " + str(predictions[0:3])
		
		GameState.add_score(10)
		
		# Update dashboard status
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

## Get simulated historical data
func _get_historical_data() -> Array:
	var data = []
	for i in range(10):
		data.append(randf_range(15.0, 35.0) + i * 0.5)
	return data
