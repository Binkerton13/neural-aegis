extends Control
## Displays scrolling log entries with color coding
## Manages auto-scroll behavior and log history

@onready var log_text: RichTextLabel = $RichTextLabel
@onready var scroll_container: ScrollContainer = $ScrollContainer

var max_log_entries: int = 1000
var log_history: Array = []
var auto_scroll: bool = true

func _ready():
	if not log_text:
		# If not loaded from scene, create programmatically
		setup_ui()

func setup_ui():
	# Create scroll container if it doesn't exist
	if not scroll_container:
		scroll_container = ScrollContainer.new()
		scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		add_child(scroll_container)
	
	# Create rich text label if it doesn't exist
	if not log_text:
		log_text = RichTextLabel.new()
		log_text.bbcode_enabled = true
		log_text.scroll_following = true
		log_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		log_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
		log_text.fit_content = true
		scroll_container.add_child(log_text)

## Add a log entry to the display
## @param entry: Dictionary with keys: timestamp, level, message, color
func add_log_entry(entry: Dictionary):
	log_history.append(entry)
	
	# Trim old entries if we exceed max
	if log_history.size() > max_log_entries:
		log_history.pop_front()
		_rebuild_log_display()
	else:
		_append_log_entry(entry)
	
	# Auto-scroll to bottom if enabled
	if auto_scroll and log_text:
		await get_tree().create_timer(0.01).timeout
		log_text.scroll_to_line(log_text.get_line_count() - 1)

## Append a single log entry to the display
func _append_log_entry(entry: Dictionary):
	if not log_text:
		return
	
	var color_hex = _color_to_hex(entry.color)
	var level_color = color_hex
	
	# Add the formatted log line
	log_text.append_text("[color=" + color_hex + "]")
	log_text.append_text("[" + entry.timestamp + "] ")
	log_text.append_text(entry.level + ": ")
	log_text.append_text(entry.message)
	log_text.append_text("[/color]\n")

## Rebuild the entire log display from history
func _rebuild_log_display():
	if not log_text:
		return
	
	log_text.clear()
	for entry in log_history:
		_append_log_entry(entry)

## Convert Color to hex string for BBCode
func _color_to_hex(color: Color) -> String:
	return "#%02x%02x%02x" % [color.r8, color.g8, color.b8]

## Toggle auto-scroll on/off
func toggle_auto_scroll():
	auto_scroll = !auto_scroll

## Set auto-scroll state
func set_auto_scroll(enabled: bool):
	auto_scroll = enabled

## Clear all log entries
func clear_logs():
	log_history.clear()
	if log_text:
		log_text.clear()

## Get the number of log entries
func get_log_count() -> int:
	return log_history.size()
