extends Node
## Simulates machine learning-based anomaly detection
## Uses statistical rules to identify suspicious patterns in game data

class_name AnomalyDetector

var baseline_metrics: Dictionary = {
	"resource_collection_mean": 20.0,
	"resource_collection_stddev": 5.0,
	"communication_frequency_normal": 0.1,
	"activity_threshold": 3.0  # 3-sigma rule
}

signal anomaly_detected(anomaly_data: Dictionary)

## Detect anomalies in current activity data
## @param current_data: Dictionary with entity activity information
## @return: Array of detected anomalies
func detect_anomalies(current_data: Dictionary) -> Array:
	var anomalies = []
	
	# Check for resource collection outliers (3-sigma rule)
	if current_data.has("collection_amount"):
		var z_score = (current_data.collection_amount - baseline_metrics.resource_collection_mean) / baseline_metrics.resource_collection_stddev
		if abs(z_score) > baseline_metrics.activity_threshold:
			var anomaly = {
				"type": "resource_outlier",
				"severity": "high" if abs(z_score) > 4 else "medium",
				"entity": current_data.get("entity_id", -1),
				"z_score": z_score,
				"description": "Unusual resource collection pattern detected"
			}
			anomalies.append(anomaly)
			anomaly_detected.emit(anomaly)
	
	# Check for unusual communication patterns
	if current_data.has("communication_count"):
		var comm_threshold = baseline_metrics.communication_frequency_normal * 5
		if current_data.communication_count > comm_threshold:
			var anomaly = {
				"type": "communication_anomaly",
				"severity": "medium",
				"entities": [
					current_data.get("source", -1),
					current_data.get("target", -1)
				],
				"description": "Elevated communication frequency detected"
			}
			anomalies.append(anomaly)
			anomaly_detected.emit(anomaly)
	
	# Check for rapid successive actions
	if current_data.has("action_frequency"):
		if current_data.action_frequency > 10:  # More than 10 actions per time unit
			var anomaly = {
				"type": "rapid_activity",
				"severity": "high",
				"entity": current_data.get("entity_id", -1),
				"description": "Suspiciously rapid activity detected"
			}
			anomalies.append(anomaly)
			anomaly_detected.emit(anomaly)
	
	# Check for access to unusual locations
	if current_data.has("location_access") and current_data.has("entity_type"):
		if current_data.location_access == "restricted" and current_data.entity_type == "threat":
			var anomaly = {
				"type": "unauthorized_access",
				"severity": "critical",
				"entity": current_data.get("entity_id", -1),
				"location": current_data.get("location_id", "unknown"),
				"description": "Unauthorized location access attempt"
			}
			anomalies.append(anomaly)
			anomaly_detected.emit(anomaly)
	
	return anomalies

## Update baseline metrics based on observed data
## Simulates model training/adaptation
func update_baseline(observation_data: Dictionary):
	if observation_data.has("collection_amount"):
		# Update running average (simple exponential smoothing)
		var alpha = 0.1  # Smoothing factor
		baseline_metrics.resource_collection_mean = (
			alpha * observation_data.collection_amount +
			(1 - alpha) * baseline_metrics.resource_collection_mean
		)

## Predict future values using simple linear trend
## Simulates time-series forecasting
func predict_trend(historical_data: Array) -> Dictionary:
	if historical_data.size() < 2:
		return {"success": false, "message": "Insufficient data"}
	
	# Simple linear regression
	var n = historical_data.size()
	var sum_x = 0.0
	var sum_y = 0.0
	var sum_xy = 0.0
	var sum_x2 = 0.0
	
	for i in range(n):
		var x = float(i)
		var y = historical_data[i]
		sum_x += x
		sum_y += y
		sum_xy += x * y
		sum_x2 += x * x
	
	var slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
	var intercept = (sum_y - slope * sum_x) / n
	
	# Predict next value
	var next_x = float(n)
	var prediction = slope * next_x + intercept
	
	return {
		"success": true,
		"prediction": prediction,
		"slope": slope,
		"trend": "increasing" if slope > 0 else "decreasing"
	}

## Identify outliers using isolation forest concept
## Returns entities that are statistical outliers
func identify_outliers(entity_data: Array) -> Array:
	if entity_data.size() < 3:
		return []
	
	# Calculate mean and standard deviation
	var sum_val = 0.0
	for entity in entity_data:
		sum_val += entity.get("value", 0.0)
	
	var mean = sum_val / entity_data.size()
	
	var sum_sq_diff = 0.0
	for entity in entity_data:
		var diff = entity.get("value", 0.0) - mean
		sum_sq_diff += diff * diff
	
	var stddev = sqrt(sum_sq_diff / entity_data.size())
	
	# Identify outliers (beyond 2 standard deviations)
	var outliers = []
	for entity in entity_data:
		var z_score = abs(entity.get("value", 0.0) - mean) / stddev if stddev > 0 else 0
		if z_score > 2.0:
			outliers.append({
				"entity": entity,
				"z_score": z_score,
				"is_outlier": true
			})
	
	return outliers
