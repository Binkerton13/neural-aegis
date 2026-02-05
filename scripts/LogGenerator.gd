extends Node
## Generates themed log entries for the scrolling log viewer
## Simulates various types of system events with configurable frequency

signal log_entry_generated(entry: Dictionary)

var log_timer: Timer
var log_interval: float = 0.5  # Generate log every 0.5 seconds (2 per second)
var entity_counter: int = 0

# Weight distribution for log types
var log_type_weights = {
	"info": 70,      # 70% normal activity
	"warning": 20,   # 20% warnings
	"alert": 10      # 10% alerts/anomalies
}

func _ready():
	setup_timer()

func setup_timer():
	log_timer = Timer.new()
	add_child(log_timer)
	log_timer.timeout.connect(_on_log_timer_timeout)
	log_timer.wait_time = log_interval
	log_timer.start()

func _on_log_timer_timeout():
	generate_log_entry()

## Generate a single log entry based on weighted random selection
func generate_log_entry():
	var log_type = _select_weighted_type()
	var entry: Dictionary
	
	match log_type:
		"info":
			entry = _generate_info_log()
		"warning":
			entry = _generate_warning_log()
		"alert":
			entry = _generate_alert_log()
	
	log_entry_generated.emit(entry)

## Select a log type based on weighted probabilities
func _select_weighted_type() -> String:
	var total_weight = 0
	for weight in log_type_weights.values():
		total_weight += weight
	
	var rand_value = randf() * total_weight
	var cumulative = 0
	
	for type in log_type_weights.keys():
		cumulative += log_type_weights[type]
		if rand_value <= cumulative:
			return type
	
	return "info"

## Generate a normal informational log entry
func _generate_info_log() -> Dictionary:
	var entity_id = randi() % 50 + 1
	var resource_amount = randi() % 30 + 5
	
	var templates = [
		"{normal_entity} {location} #{id} collected {amount} {resource_plural}",
		"{normal_entity} #{id} performed routine check",
		"{normal_entity} nest #{id} activity normal",
		"Regular patrol by {normal_entity} #{id} completed"
	]
	
	var template = templates[randi() % templates.size()]
	var message = template.format({
		"normal_entity": ThemeManager.get_term("normal_entity").capitalize(),
		"location": ThemeManager.get_term("location"),
		"id": entity_id,
		"amount": resource_amount,
		"resource_plural": ThemeManager.get_term("resource_plural")
	})
	
	return {
		"timestamp": _get_timestamp(),
		"level": "INFO",
		"message": message,
		"color": Color.WHITE,
		"entity_id": entity_id
	}

## Generate a warning log entry
func _generate_warning_log() -> Dictionary:
	var entity_id = randi() % 20 + 1
	var resource_amount = randi() % 30 + 40  # Higher than normal
	
	var templates = [
		"{threat_actor} {location} #{id} gathered {amount} {resource_plural} (above average)",
		"Elevated activity at {location} #{id}",
		"Unusual {resource} accumulation by {threat_actor} #{id}",
		"{threat_actor} #{id} behavior deviation detected"
	]
	
	var template = templates[randi() % templates.size()]
	var message = template.format({
		"threat_actor": ThemeManager.get_term("threat_actor").capitalize(),
		"location": ThemeManager.get_term("location"),
		"id": entity_id,
		"amount": resource_amount,
		"resource": ThemeManager.get_term("resource"),
		"resource_plural": ThemeManager.get_term("resource_plural")
	})
	
	return {
		"timestamp": _get_timestamp(),
		"level": "WARN",
		"message": message,
		"color": Color.YELLOW,
		"entity_id": entity_id
	}

## Generate an alert/anomaly log entry
func _generate_alert_log() -> Dictionary:
	var source_id = randi() % 20 + 1
	var target_id = randi() % 20 + 1
	
	var templates = [
		"Unusual communication detected: {threat_actor}#{source} -> {secondary_threat}#{target}",
		"ALERT: {threat_actor} #{source} accessing unauthorized {location}",
		"Coordinated activity: {threat_actor}#{source} and {threat_actor}#{target}",
		"Security breach attempt by {threat_actor} #{source}"
	]
	
	var template = templates[randi() % templates.size()]
	var message = template.format({
		"threat_actor": ThemeManager.get_term("threat_actor").capitalize(),
		"secondary_threat": ThemeManager.get_term("secondary_threat"),
		"location": ThemeManager.get_term("location"),
		"source": source_id,
		"target": target_id
	})
	
	# Notify GameState of threat detection
	GameState.detect_threat({
		"entity_id": source_id,
		"type": "anomaly",
		"severity": "high"
	})
	
	return {
		"timestamp": _get_timestamp(),
		"level": "ALERT",
		"message": message,
		"color": Color.RED,
		"entity_id": source_id
	}

## Get current timestamp in HH:MM:SS format
func _get_timestamp() -> String:
	var time = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [time.hour, time.minute, time.second]

## Set the log generation interval
func set_log_interval(interval: float):
	log_interval = interval
	if log_timer:
		log_timer.wait_time = interval

## Start log generation
func start():
	if log_timer:
		log_timer.start()

## Stop log generation
func stop():
	if log_timer:
		log_timer.stop()
