extends Node
## Manages the drag-and-drop tool system
## Coordinates tool usage and provides drop zone functionality

signal tool_dropped(tool_name: String, position: Vector2)
signal tool_used_on_target(tool_name: String, target: Node)

var active_drag_data = null
var drop_zones: Array = []

## Register a control as a drop zone for tools
func register_drop_zone(control: Control):
	if not drop_zones.has(control):
		drop_zones.append(control)

## Unregister a drop zone
func unregister_drop_zone(control: Control):
	drop_zones.erase(control)

## Handle tool being used on a specific target
func use_tool_on_target(tool: Tool, target_node: Node, target_data: Dictionary = {}):
	if not tool or not tool.can_use:
		return
	
	var result = tool.use_tool(target_data)
	
	if result.success:
		tool_used_on_target.emit(tool.tool_name, target_node)
		print("Tool '", tool.tool_name, "' used successfully: ", result.message)
	else:
		print("Tool usage failed: ", result.message)
	
	return result

## Get all registered drop zones
func get_drop_zones() -> Array:
	return drop_zones
