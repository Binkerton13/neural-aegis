extends Node
## HTTP Client for communicating with Python ML service
## Provides real machine learning capabilities via REST API

const ML_SERVICE_URL = "http://localhost:5000"

var http_client: HTTPRequest
var ml_service_available: bool = false

signal ml_response_received(endpoint: String, result: Dictionary)
signal ml_error(endpoint: String, error: String)

func _ready():
	setup_http_client()
	check_ml_service()

func setup_http_client():
	http_client = HTTPRequest.new()
	add_child(http_client)
	http_client.request_completed.connect(_on_request_completed)

func check_ml_service():
	"""Check if ML service is available"""
	var url = ML_SERVICE_URL + "/health"
	var error = http_client.request(url)
	
	if error != OK:
		print("ML Service: Connection check failed")
		ml_service_available = false
	else:
		print("ML Service: Checking availability...")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var json = JSON.new()
	var body_string = body.get_string_from_utf8()
	
	if response_code == 200:
		var parse_result = json.parse(body_string)
		if parse_result == OK:
			var data = json.data
			
			# Check if this was a health check
			if data.has("status") and data["status"] == "healthy":
				ml_service_available = true
				print("ML Service: Available and healthy")
				return
			
			# Otherwise, emit the response
			ml_response_received.emit("", data)
		else:
			ml_error.emit("", "Failed to parse JSON response")
	else:
		ml_service_available = false
		ml_error.emit("", "HTTP error: " + str(response_code))

func isolation_forest(data: Array, contamination: float = 0.1) -> void:
	"""
	Call Isolation Forest endpoint for outlier detection
	
	Args:
		data: Array of values to analyze
		contamination: Expected proportion of outliers (0.0 to 0.5)
	"""
	if not ml_service_available:
		ml_error.emit("isolation_forest", "ML service not available")
		return
	
	var url = ML_SERVICE_URL + "/isolation_forest"
	var headers = ["Content-Type: application/json"]
	
	var request_data = {
		"data": data,
		"contamination": contamination
	}
	
	var json_string = JSON.stringify(request_data)
	var error = http_client.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		ml_error.emit("isolation_forest", "Request failed: " + str(error))

func linear_regression(data: Array, forecast_steps: int = 5) -> void:
	"""
	Call Linear Regression endpoint for time-series forecasting
	
	Args:
		data: Array of historical values
		forecast_steps: Number of future steps to predict
	"""
	if not ml_service_available:
		ml_error.emit("linear_regression", "ML service not available")
		return
	
	var url = ML_SERVICE_URL + "/linear_regression"
	var headers = ["Content-Type: application/json"]
	
	var request_data = {
		"data": data,
		"forecast_steps": forecast_steps
	}
	
	var json_string = JSON.stringify(request_data)
	var error = http_client.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		ml_error.emit("linear_regression", "Request failed: " + str(error))

func anomaly_detection(data: Array, threshold: float = 3.0) -> void:
	"""
	Call anomaly detection endpoint using 3-sigma rule
	
	Args:
		data: Array of values to analyze
		threshold: Number of standard deviations for anomaly threshold
	"""
	if not ml_service_available:
		ml_error.emit("anomaly_detection", "ML service not available")
		return
	
	var url = ML_SERVICE_URL + "/anomaly_detection"
	var headers = ["Content-Type: application/json"]
	
	var request_data = {
		"data": data,
		"threshold": threshold
	}
	
	var json_string = JSON.stringify(request_data)
	var error = http_client.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		ml_error.emit("anomaly_detection", "Request failed: " + str(error))

func is_available() -> bool:
	"""Check if ML service is available"""
	return ml_service_available
