extends Node
## Global game state manager
## AutoLoad singleton that tracks score, resources, threats, and game progress

var score: int = 0
var resources: int = 100
var threats_detected: int = 0
var threats_neutralized: int = 0
var active_tools: Array = []
var game_time: float = 0.0
var game_running: bool = true

signal score_changed(new_score: int)
signal resource_changed(new_amount: int)
signal threat_detected(threat_data: Dictionary)
signal threat_neutralized(threat_data: Dictionary)
signal tool_used(tool_name: String, target_data: Dictionary)

func _process(delta):
	if game_running:
		game_time += delta

## Add points to the score
## @param amount: Points to add (can be negative)
func add_score(amount: int):
	score += amount
	score_changed.emit(score)
	print("Score changed: ", score)

## Consume resources if available
## @param amount: Amount of resources to consume
## @return: true if resources were available and consumed, false otherwise
func consume_resources(amount: int) -> bool:
	if resources >= amount:
		resources -= amount
		resource_changed.emit(resources)
		print("Resources consumed: ", amount, " (remaining: ", resources, ")")
		return true
	else:
		print("Insufficient resources: need ", amount, " but only have ", resources)
		return false

## Add resources
## @param amount: Amount of resources to add
func add_resources(amount: int):
	resources += amount
	resource_changed.emit(resources)
	print("Resources added: ", amount, " (total: ", resources, ")")

## Report a detected threat
## @param threat_data: Dictionary containing threat information
func detect_threat(threat_data: Dictionary):
	threats_detected += 1
	threat_detected.emit(threat_data)
	print("Threat detected (#", threats_detected, "): ", threat_data)

## Report a neutralized threat
## @param threat_data: Dictionary containing threat information
func neutralize_threat(threat_data: Dictionary):
	threats_neutralized += 1
	threat_neutralized.emit(threat_data)
	add_score(10)  # Reward for neutralizing threats
	print("Threat neutralized (#", threats_neutralized, "): ", threat_data)

## Register a tool as active
## @param tool_name: Name of the tool
## @param duration: How long the tool remains active (0 for instant)
func register_tool_use(tool_name: String, target_data: Dictionary, duration: float = 0.0):
	tool_used.emit(tool_name, target_data)
	if duration > 0.0:
		active_tools.append({"name": tool_name, "time_remaining": duration})
	print("Tool used: ", tool_name)

## Reset game state
func reset_game():
	score = 0
	resources = 100
	threats_detected = 0
	threats_neutralized = 0
	active_tools.clear()
	game_time = 0.0
	game_running = true
	score_changed.emit(score)
	resource_changed.emit(resources)
	print("Game state reset")

## Pause the game
func pause_game():
	game_running = false

## Resume the game
func resume_game():
	game_running = true
