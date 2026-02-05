extends Control
## Base class for all analyst tools
## Provides drag-and-drop functionality and cooldown management

class_name Tool

@export var tool_name: String = "Base Tool"
@export var tool_description: String = "Description"
@export var cooldown_time: float = 5.0
@export var real_world_equivalent: String = ""
@export var resource_cost: int = 5

var is_dragging: bool = false
var can_use: bool = true
var cooldown_remaining: float = 0.0

signal tool_used(tool_name: String, result: Dictionary)
signal cooldown_started(duration: float)
signal cooldown_finished()

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS

func _process(delta):
	if cooldown_remaining > 0:
		cooldown_remaining -= delta
		if cooldown_remaining <= 0:
			cooldown_remaining = 0
			can_use = true
			cooldown_finished.emit()

## Use the tool on a target
## Override this in subclasses to implement tool-specific behavior
## @param target_data: Dictionary containing target information
## @return: Dictionary with "success" bool and "message" string
func use_tool(target_data: Dictionary) -> Dictionary:
	if not can_use:
		return {"success": false, "message": "Tool is on cooldown"}
	
	if not GameState.consume_resources(resource_cost):
		return {"success": false, "message": "Insufficient resources"}
	
	# Start cooldown
	can_use = false
	cooldown_remaining = cooldown_time
	cooldown_started.emit(cooldown_time)
	
	# Register with GameState
	GameState.register_tool_use(tool_name, target_data, cooldown_time)
	
	# Default implementation - override in subclasses
	var result = {"success": true, "message": "Tool used successfully"}
	tool_used.emit(tool_name, result)
	return result

## Get drag data for drag-and-drop operation
func _get_drag_data(_at_position: Vector2):
	if not can_use:
		return null
	
	# Create a preview of the tool being dragged
	var preview = Label.new()
	preview.text = tool_name
	preview.modulate = Color(1, 1, 1, 0.7)
	
	set_drag_preview(preview)
	
	return {
		"type": "tool",
		"tool_instance": self,
		"tool_name": tool_name
	}

## Check if this control can drop the given data
func _can_drop_data(_at_position: Vector2, data) -> bool:
	return data is Dictionary and data.has("type") and data["type"] == "tool"

## Handle dropped data
func _drop_data(_at_position: Vector2, data):
	if data.has("tool_instance"):
		var tool = data["tool_instance"]
		if tool and tool.has_method("use_tool"):
			tool.use_tool({})

## Get tooltip text
func _make_tooltip(_at_position: Vector2) -> String:
	var tooltip = "[b]" + tool_name + "[/b]\n"
	tooltip += tool_description + "\n\n"
	tooltip += "[i]Real-world: " + real_world_equivalent + "[/i]\n"
	tooltip += "Cooldown: " + str(cooldown_time) + "s\n"
	tooltip += "Cost: " + str(resource_cost) + " resources\n"
	
	if not can_use:
		tooltip += "\n[color=red]On cooldown: " + str(ceil(cooldown_remaining)) + "s[/color]"
	
	return tooltip
