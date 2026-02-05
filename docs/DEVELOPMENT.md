# Development Guide

This guide provides detailed instructions for extending Neural Aegis with new tools, themes, and features.

## Project Structure

```
neural-aegis/
├── project.godot           # Godot project configuration
├── scenes/                 # Scene files (.tscn)
│   ├── Main.tscn          # Entry point
│   ├── MainDashboard.tscn # Main UI
│   ├── LogViewer.tscn     # Log display
│   └── ToolPalette.tscn   # Tool panel
├── scripts/               # Core game scripts
│   ├── Main.gd
│   ├── MainDashboard.gd
│   ├── LogGenerator.gd
│   ├── LogViewer.gd
│   ├── ThemeManager.gd    # AutoLoad
│   ├── GameState.gd       # AutoLoad
│   ├── ToolSystem.gd
│   ├── Tool.gd            # Base class
│   └── AnomalyDetector.gd
├── tools/                 # Tool implementations
│   ├── LinearRegressionTool.gd
│   ├── IsolationForestTool.gd
│   ├── HoneypotTool.gd
│   ├── TraceTool.gd
│   └── SnareTool.gd
├── data/                  # Data files
│   └── themes.json
├── assets/                # Art, fonts, audio
│   └── fonts/
└── docs/                  # Documentation
```

## AutoLoad Singletons

### ThemeManager
- **Path**: `scripts/ThemeManager.gd`
- **Purpose**: Global theme state and translation
- **Access**: `ThemeManager.get_term("key")`

### GameState
- **Path**: `scripts/GameState.gd`
- **Purpose**: Global game state (score, resources, threats)
- **Access**: `GameState.score`, `GameState.add_score(10)`

## Adding a New Tool

Follow these steps to add a new analyst tool:

### Step 1: Create Tool Script

Create `tools/YourToolName.gd`:

```gdscript
extends Tool
## Brief description of what this tool does
## Relates to [real-world technique]

func _ready():
	super._ready()  # IMPORTANT: Call parent _ready()
	
	# Configure tool properties
	tool_name = "Your Tool Name"
	tool_description = "What the tool does in-game"
	real_world_equivalent = "Real-world analyst technique it represents"
	cooldown_time = 10.0  # Seconds between uses
	resource_cost = 15  # Resources consumed per use

func use_tool(target_data: Dictionary) -> Dictionary:
	# IMPORTANT: Call parent to handle cooldown and resources
	var base_result = super.use_tool(target_data)
	if not base_result.success:
		return base_result
	
	# Your tool-specific logic here
	# Example: Analyze data, detect patterns, etc.
	
	# Award points if successful
	GameState.add_score(10)
	
	# Optionally interact with other systems
	# GameState.neutralize_threat({"entity_id": 123})
	
	# Return result
	return {
		"success": true,
		"message": "Tool executed successfully: details here",
		# Add any custom data you want to return
	}
```

### Step 2: Add to Tool Palette Scene

1. Open `scenes/ToolPalette.tscn` in Godot editor
2. Add a new `HSeparator` node
3. Add a new `Button` node after the separator:
   - Set `custom_minimum_size`: `(0, 80)`
   - Set `text`: Your tool name (use line breaks if needed)
   - Set `tooltip_text`: Full description
4. Attach your tool script to the button:
   - Click the button node
   - In Inspector, Script → Load → Select your tool script
5. Save the scene

**Alternative: Manual .tscn editing**

Add to `scenes/ToolPalette.tscn`:

```
[node name="YourToolButton" type="Button" parent="."]
custom_minimum_size = Vector2(0, 80)
layout_mode = 2
tooltip_text = "Your Tool Name
Description of what it does

Real-world: The technique it represents
Cooldown: 10s | Cost: 15 resources"
text = "Your Tool
Name"
script = ExtResource("X")  # Reference to your tool script
```

### Step 3: Test Your Tool

1. Run the game (F5)
2. Verify button appears in palette
3. Hover to see tooltip
4. Click to use tool
5. Check:
   - Resources decrease by cost amount
   - Cooldown prevents immediate reuse
   - Status bar shows tool action
   - Score increases (if applicable)
   - Console shows no errors

### Example: Creating a "Firewall" Tool

```gdscript
extends Tool
## Firewall tool that blocks threat communications
## Simulates network security firewall rules

func _ready():
	super._ready()
	tool_name = "Firewall"
	tool_description = "Block malicious network traffic"
	real_world_equivalent = "Next-gen firewall, IPS rules"
	cooldown_time = 7.0
	resource_cost = 10

func use_tool(target_data: Dictionary) -> Dictionary:
	var base_result = super.use_tool(target_data)
	if not base_result.success:
		return base_result
	
	# Simulate blocking traffic
	var blocked_count = randi() % 5 + 1
	var threat_name = ThemeManager.get_term("threat_actor")
	
	var message = "Firewall rule deployed. Blocked "
	message += str(blocked_count) + " " + threat_name
	message += " connections"
	
	# Neutralize blocked threats
	for i in range(blocked_count):
		GameState.neutralize_threat({
			"entity_id": randi() % 20 + 1,
			"method": "firewall_block"
		})
	
	GameState.add_score(5 * blocked_count)
	
	return {
		"success": true,
		"message": message,
		"blocked_count": blocked_count
	}
```

## Adding a New Theme

### Step 1: Edit themes.json

Add your theme to `data/themes.json`:

```json
{
  "existing_themes": "...",
  "your_theme_key": {
    "name": "Display Name",
    "threat_actor": "primary bad actor (singular)",
    "threat_actor_plural": "primary bad actors (plural)",
    "secondary_threat": "secondary threat (singular)",
    "secondary_threat_plural": "secondary threats (plural)",
    "resource": "valuable thing (singular)",
    "resource_plural": "valuable things (plural)",
    "location": "place where things happen (singular)",
    "location_plural": "places (plural)",
    "defensive_action": "defensive measure name",
    "honeypot": "decoy/trap name",
    "honeypot_bait": "what lures threats",
    "trace_action": "tracking/tracing verb",
    "normal_entity": "good actor (singular)",
    "normal_entity_plural": "good actors (plural)"
  }
}
```

### Step 2: Test Theme

1. Run the game
2. Open theme dropdown
3. Select your new theme
4. Verify:
   - Theme name appears in dropdown
   - Logs use your terminology
   - Tool messages use themed terms
   - All terms make sense together

### Example: Space Station Theme

```json
"space_station": {
  "name": "Space Station",
  "threat_actor": "pirate ship",
  "threat_actor_plural": "pirate ships",
  "secondary_threat": "alien vessel",
  "secondary_threat_plural": "alien vessels",
  "resource": "energy credit",
  "resource_plural": "energy credits",
  "location": "sector",
  "location_plural": "sectors",
  "defensive_action": "shield",
  "honeypot": "decoy beacon",
  "honeypot_bait": "distress signal",
  "trace_action": "scan",
  "normal_entity": "trading vessel",
  "normal_entity_plural": "trading vessels"
}
```

## Customizing Log Generation

Edit `scripts/LogGenerator.gd` to add new log patterns:

### Adding a Log Template

```gdscript
func _generate_info_log() -> Dictionary:
	# ... existing templates ...
	
	var templates = [
		# Add your new template
		"Your custom log message with {normal_entity} #{id}",
		# ... existing templates ...
	]
	
	# Template will be randomly selected
```

### Adding a New Log Level

```gdscript
# Add weight to distribution
var log_type_weights = {
	"info": 70,
	"warning": 20,
	"alert": 10,
	"your_new_type": 5  # New type
}

# Add generation function
func _generate_your_new_type_log() -> Dictionary:
	return {
		"timestamp": _get_timestamp(),
		"level": "CUSTOM",
		"message": "Custom message",
		"color": Color.CYAN,  # Choose color
		"entity_id": 0
	}

# Add to match statement
match log_type:
	"info":
		entry = _generate_info_log()
	# ... existing cases ...
	"your_new_type":
		entry = _generate_your_new_type_log()
```

## Modifying the UI

### Changing Colors

Edit the tool palette style in `scenes/ToolPalette.tscn`:

```gdscript
[sub_resource type="StyleBoxFlat" id="1"]
bg_color = Color(0.2, 0.2, 0.25, 1)  # Background
border_color = Color(0.4, 0.4, 0.5, 1)  # Border
```

### Adding UI Elements

1. Open `scenes/MainDashboard.tscn`
2. Add nodes to appropriate containers:
   - `TopBar` - Header information
   - `ContentArea` - Main game area
   - `BottomBar` - Status/footer
3. Access in `scripts/MainDashboard.gd`:
```gdscript
@onready var your_element = $MainLayout/YourPath/YourElement
```

## Working with Signals

### Listening to GameState Events

```gdscript
func _ready():
	GameState.score_changed.connect(_on_score_changed)
	GameState.threat_detected.connect(_on_threat_detected)

func _on_score_changed(new_score: int):
	print("Score is now: ", new_score)

func _on_threat_detected(threat_data: Dictionary):
	print("Threat detected: ", threat_data)
```

### Creating Custom Signals

```gdscript
signal custom_event(data: Dictionary)

func trigger_event():
	custom_event.emit({"key": "value"})
```

## Debugging Tips

### Enable Verbose Logging

Add print statements:
```gdscript
print("Debug: Variable value = ", my_var)
push_warning("This is a warning")
push_error("This is an error")
```

### Check Godot Console

Run game and watch the Output panel:
- Blue = print()
- Yellow = push_warning()
- Red = push_error()

### Common Issues

**Tool not appearing:**
- Check script is attached to button
- Verify scene file is saved
- Check console for errors

**Theme not switching:**
- Verify JSON syntax is valid
- Check all required keys present
- Look for ThemeManager errors in console

**Resources not updating:**
- Ensure `GameState.consume_resources()` is called
- Check `resource_cost` is set
- Verify signal connections

## Performance Optimization

### Reducing Log Spam

Adjust timer interval in LogGenerator:
```gdscript
var log_interval: float = 1.0  # Generate every 1 second
```

### Limiting Log History

Change max entries in LogViewer:
```gdscript
var max_log_entries: int = 500  # Keep only 500 entries
```

## Next Steps

- Read [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Check [ROADMAP.md](ROADMAP.md) for upcoming features
- See [CONTRIBUTING.md](CONTRIBUTING.md) for PR guidelines
- Review existing tool implementations for examples

## Getting Help

- Check [GitHub Issues](https://github.com/Binkerton13/neural-aegis/issues)
- Review [Godot documentation](https://docs.godotengine.org/)
- Ask questions in project discussions
