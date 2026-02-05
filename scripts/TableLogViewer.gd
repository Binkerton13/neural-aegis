extends Control
## Table-based log viewer with columns for timestamp, level, entity, and message
## Supports row selection for interactive tool use

@onready var table: Tree = $VBoxContainer/Tree
@onready var controls: HBoxContainer = $VBoxContainer/Controls

var max_log_entries: int = 1000
var log_history: Array = []
var auto_scroll: bool = true
var selected_rows: Array = []

# Column indices
enum Column {
	TIMESTAMP,
	LEVEL,
	ENTITY,
	MESSAGE
}

func _ready():
	setup_table()

func setup_table():
	if not table:
		# Create tree if it doesn't exist
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		add_child(vbox)
		
		# Add controls
		controls = HBoxContainer.new()
		var auto_scroll_button = CheckButton.new()
		auto_scroll_button.text = "Auto-scroll"
		auto_scroll_button.button_pressed = auto_scroll
		auto_scroll_button.toggled.connect(_on_auto_scroll_toggled)
		controls.add_child(auto_scroll_button)
		vbox.add_child(controls)
		
		# Add table
		table = Tree.new()
		table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		table.size_flags_vertical = Control.SIZE_EXPAND_FILL
		table.hide_root = true
		table.select_mode = Tree.SELECT_MULTI
		vbox.add_child(table)
	
	# Configure columns
	table.columns = 4
	table.set_column_title(Column.TIMESTAMP, "Time")
	table.set_column_title(Column.LEVEL, "Level")
	table.set_column_title(Column.ENTITY, "Entity")
	table.set_column_title(Column.MESSAGE, "Message")
	
	# Set column sizing
	table.set_column_expand(Column.TIMESTAMP, false)
	table.set_column_custom_minimum_width(Column.TIMESTAMP, 80)
	table.set_column_expand(Column.LEVEL, false)
	table.set_column_custom_minimum_width(Column.LEVEL, 60)
	table.set_column_expand(Column.ENTITY, false)
	table.set_column_custom_minimum_width(Column.ENTITY, 80)
	table.set_column_expand(Column.MESSAGE, true)
	
	table.column_titles_visible = true
	
	# Create root
	if not table.get_root():
		table.create_item()
	
	# Connect signals
	table.multi_selected.connect(_on_row_selected)

func _on_auto_scroll_toggled(enabled: bool):
	auto_scroll = enabled

func _on_row_selected(item: TreeItem, _column: int, selected: bool):
	if selected:
		if not selected_rows.has(item):
			selected_rows.append(item)
	else:
		selected_rows.erase(item)

## Add a log entry to the display
## @param entry: Dictionary with keys: timestamp, level, message, color, entity_id
func add_log_entry(entry: Dictionary):
	log_history.append(entry)
	
	# Trim old entries if we exceed max
	if log_history.size() > max_log_entries:
		log_history.pop_front()
		_rebuild_table()
	else:
		_append_log_row(entry)
	
	# Auto-scroll to bottom if enabled
	if auto_scroll and table:
		await get_tree().create_timer(0.01).timeout
		var last_item = _get_last_item()
		if last_item:
			table.scroll_to_item(last_item)

func _append_log_row(entry: Dictionary):
	if not table or not table.get_root():
		return
	
	var item = table.create_item(table.get_root())
	
	# Timestamp
	item.set_text(Column.TIMESTAMP, entry.get("timestamp", ""))
	
	# Level
	var level = entry.get("level", "INFO")
	item.set_text(Column.LEVEL, level)
	
	# Color code the level
	var color = entry.get("color", Color.WHITE)
	item.set_custom_color(Column.LEVEL, color)
	
	# Entity
	var entity_id = entry.get("entity_id", "")
	item.set_text(Column.ENTITY, str(entity_id) if entity_id else "")
	
	# Message
	item.set_text(Column.MESSAGE, entry.get("message", ""))
	
	# Store the full entry data in metadata
	item.set_metadata(0, entry)

func _rebuild_table():
	if not table or not table.get_root():
		return
	
	# Clear existing items
	table.clear()
	table.create_item()
	
	# Re-add all entries
	for entry in log_history:
		_append_log_row(entry)

func _get_last_item() -> TreeItem:
	if not table or not table.get_root():
		return null
	
	var item = table.get_root().get_first_child()
	if not item:
		return null
	
	while item.get_next():
		item = item.get_next()
	
	return item

## Get selected log entries
func get_selected_entries() -> Array:
	var entries = []
	for item in selected_rows:
		var metadata = item.get_metadata(0)
		if metadata:
			entries.append(metadata)
	return entries

## Clear selection
func clear_selection():
	selected_rows.clear()
	if table:
		table.deselect_all()

## Toggle auto-scroll on/off
func toggle_auto_scroll():
	auto_scroll = !auto_scroll

## Set auto-scroll state
func set_auto_scroll(enabled: bool):
	auto_scroll = enabled

## Clear all log entries
func clear_logs():
	log_history.clear()
	selected_rows.clear()
	if table:
		table.clear()
		table.create_item()

## Get the number of log entries
func get_log_count() -> int:
	return log_history.size()

## Enable drag and drop on this control
func _can_drop_data(_at_position: Vector2, data) -> bool:
	return data is Dictionary and data.has("type") and data["type"] == "tool"

## Handle tool drop
func _drop_data(at_position: Vector2, data):
	if not data.has("tool_instance"):
		return
	
	var tool = data["tool_instance"]
	if not tool or not tool.has_method("use_tool"):
		return
	
	# Get the item at the drop position
	var item = table.get_item_at_position(at_position)
	
	# If we have selected rows, use those; otherwise use the dropped item
	var target_entries = []
	if selected_rows.size() > 0:
		target_entries = get_selected_entries()
	elif item:
		var metadata = item.get_metadata(0)
		if metadata:
			target_entries.append(metadata)
	
	# Use the tool with the target entries
	if target_entries.size() > 0:
		var result = tool.use_tool({"target_entries": target_entries})
		# Clear selection after use
		clear_selection()
