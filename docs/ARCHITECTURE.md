# Architecture Overview

This document explains the technical architecture of Neural Aegis, including scene hierarchy, signal flow, and system interactions.

## System Architecture

```
┌─────────────────────────────────────────────────┐
│              AutoLoad Singletons                │
│  ┌────────────────┐    ┌──────────────────┐    │
│  │ ThemeManager   │    │   GameState      │    │
│  │ - Theme data   │    │ - Score/resources│    │
│  │ - Translation  │    │ - Threat tracking│    │
│  └────────────────┘    └──────────────────┘    │
└─────────────────────────────────────────────────┘
                    ▲
                    │ Signals
                    ▼
┌─────────────────────────────────────────────────┐
│                 Main Scene                      │
│              (Entry Point)                      │
└─────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│             MainDashboard                       │
│  ┌──────────────┐  ┌────────────────────────┐  │
│  │ToolPalette   │  │    LogViewer          │  │
│  │ - Tool UI    │  │  - RichTextLabel      │  │
│  │ - Buttons    │  │  - Auto-scroll        │  │
│  └──────────────┘  └────────────────────────┘  │
│         ▲                    ▲                  │
│         │                    │                  │
│    ┌────┴────┐         ┌────┴─────┐           │
│    │  Tools  │         │LogGen.   │           │
│    └─────────┘         └──────────┘           │
└─────────────────────────────────────────────────┘
```

## Core Components

### 1. AutoLoad Singletons

These are globally accessible throughout the game:

#### ThemeManager (`scripts/ThemeManager.gd`)
**Responsibility**: Manage theme switching and terminology translation

**Key Functions**:
- `load_themes()` - Load theme data from JSON
- `get_term(key: String) -> String` - Get themed terminology
- `switch_theme(theme_name: String)` - Change active theme
- `get_available_themes() -> Array` - List all themes

**Signals**:
- `theme_changed(new_theme: String)` - Emitted when theme switches

**Data Flow**:
```
themes.json → ThemeManager.load_themes() → theme_data
                              ↓
              components call get_term() → themed string
```

#### GameState (`scripts/GameState.gd`)
**Responsibility**: Track global game state and statistics

**Key Functions**:
- `add_score(amount: int)` - Modify player score
- `consume_resources(amount: int) -> bool` - Use resources
- `detect_threat(threat_data: Dictionary)` - Register threat
- `neutralize_threat(threat_data: Dictionary)` - Mark threat handled

**Signals**:
- `score_changed(new_score: int)`
- `resource_changed(new_amount: int)`
- `threat_detected(threat_data: Dictionary)`
- `threat_neutralized(threat_data: Dictionary)`
- `tool_used(tool_name: String, target_data: Dictionary)`

### 2. Scene Hierarchy

```
Main (Node)
└── MainDashboard (Control)
    ├── TopBar (PanelContainer)
    │   ├── Title
    │   ├── ThemeSelector (OptionButton)
    │   └── StatsPanel (Score, Threats, Resources)
    ├── ContentArea (HBoxContainer)
    │   ├── ToolPalette (VBoxContainer)
    │   │   ├── LinearRegression (Button + Tool script)
    │   │   ├── IsolationForest (Button + Tool script)
    │   │   ├── Honeypot (Button + Tool script)
    │   │   ├── Trace (Button + Tool script)
    │   │   └── Snare (Button + Tool script)
    │   └── LogViewer (Control)
    │       └── ScrollContainer
    │           └── RichTextLabel
    └── BottomBar (PanelContainer)
        └── StatusLabel
```

### 3. Signal Flow

```
┌──────────────┐      log_entry_generated      ┌──────────────┐
│LogGenerator  │─────────────────────────────→│ LogViewer    │
└──────────────┘                                └──────────────┘

┌──────────────┐      tool_used                 ┌──────────────┐
│   Tool       │─────────────────────────────→│  GameState   │
└──────────────┘                                └──────────────┘

┌──────────────┐    score_changed/etc.          ┌──────────────┐
│  GameState   │─────────────────────────────→│MainDashboard │
└──────────────┘                                └──────────────┘

┌──────────────┐    theme_changed               ┌──────────────┐
│ThemeManager  │─────────────────────────────→│ All UI       │
└──────────────┘                                └──────────────┘
```

### 4. Log Generation System

**LogGenerator** (`scripts/LogGenerator.gd`)

Generates themed log entries at configurable intervals:

```gdscript
Timer (0.5s) → _on_log_timer_timeout()
                    ↓
              _select_weighted_type()
                    ↓
        ┌───────────┼───────────┐
        ▼           ▼           ▼
    _generate_  _generate_  _generate_
    info_log    warning_log  alert_log
        │           │           │
        └───────────┴───────────┘
                    ↓
          log_entry_generated signal
                    ↓
              LogViewer.add_log_entry()
```

**Log Entry Structure**:
```gdscript
{
    "timestamp": "12:34:56",
    "level": "INFO" | "WARN" | "ALERT",
    "message": "Themed message string",
    "color": Color.WHITE | Color.YELLOW | Color.RED,
    "entity_id": 123
}
```

### 5. Tool System

**Tool Base Class** (`scripts/Tool.gd`)

All analyst tools inherit from this:

```gdscript
Tool (extends Control)
├── Properties
│   ├── tool_name: String
│   ├── tool_description: String
│   ├── cooldown_time: float
│   ├── real_world_equivalent: String
│   ├── resource_cost: int
│   ├── can_use: bool
│   └── cooldown_remaining: float
├── Methods
│   ├── use_tool(target_data: Dictionary) -> Dictionary
│   ├── _get_drag_data() → For drag-and-drop
│   └── _process(delta) → Cooldown management
└── Signals
    ├── tool_used
    ├── cooldown_started
    └── cooldown_finished
```

**Tool Lifecycle**:
```
User clicks tool button
        ↓
Tool.use_tool() called
        ↓
Check can_use and resources
        ↓
GameState.consume_resources()
        ↓
Execute tool-specific logic
        ↓
Start cooldown timer
        ↓
Emit tool_used signal
        ↓
_process() updates cooldown
        ↓
Emit cooldown_finished when ready
```

### 6. Anomaly Detection System

**AnomalyDetector** (`scripts/AnomalyDetector.gd`)

Simulates ML-based anomaly detection:

**Detection Methods**:
1. **Statistical Outliers** - 3-sigma rule for resource collection
2. **Communication Anomalies** - Frequency threshold detection
3. **Rapid Activity** - Action frequency analysis
4. **Unauthorized Access** - Location-based detection

**Integration**:
```
LogGenerator detects anomaly
        ↓
Creates ALERT log entry
        ↓
Calls GameState.detect_threat()
        ↓
threat_detected signal emitted
        ↓
MainDashboard updates UI
```

## Data Flow Examples

### Example 1: Player Uses a Tool

```
1. Player clicks "Honeypot" button
2. HoneypotTool.use_tool({}) called
3. Tool checks can_use (cooldown status)
4. GameState.consume_resources(20) called
5. GameState emits resource_changed signal
6. MainDashboard updates ResourcesLabel
7. HoneypotTool executes deploy logic
8. HoneypotTool.tool_used signal emitted
9. GameState.register_tool_use() called
10. Tool starts cooldown timer
11. MainDashboard updates StatusLabel
```

### Example 2: Theme Switch

```
1. Player selects "Cyberpunk" from dropdown
2. MainDashboard._on_theme_selected() called
3. ThemeManager.switch_theme("cyber") called
4. ThemeManager emits theme_changed signal
5. MainDashboard._on_theme_changed() called
6. LogViewer.clear_logs() called
7. LogGenerator continues with new theme terms
8. New logs use "botnet" instead of "fox"
```

### Example 3: Anomaly Detection

```
1. LogGenerator generates alert log
2. Calls GameState.detect_threat({...})
3. GameState increments threats_detected
4. GameState emits threat_detected signal
5. MainDashboard updates ThreatsLabel
6. MainDashboard updates StatusLabel
7. Red ALERT message appears in LogViewer
```

## Extension Points

### Adding a New Tool

1. Create `tools/YourTool.gd` extending `Tool`
2. Override `use_tool()` method
3. Set exports in `_ready()`
4. Add button to `scenes/ToolPalette.tscn`
5. Connect button.pressed signal

### Adding a New Theme

1. Add theme object to `data/themes.json`
2. Include all required keys
3. Theme automatically loaded by ThemeManager
4. Available in theme selector

### Adding a New Log Type

1. Add type to `LogGenerator.log_type_weights`
2. Create `_generate_[type]_log()` function
3. Add case to `generate_log_entry()` match statement
4. Define color and format

## Performance Considerations

- **Log Trimming**: LogViewer limits history to 1000 entries
- **Timer Intervals**: Log generation at 0.5s intervals (2/second)
- **Cooldown Timers**: Tools use `_process()` for cooldown tracking
- **Signal Efficiency**: Direct connections without unnecessary intermediaries

## Testing Strategy

- **Manual Testing**: Run game and verify UI updates
- **Theme Testing**: Switch themes and verify terminology changes
- **Tool Testing**: Use each tool and verify resource consumption
- **Log Testing**: Verify color coding and auto-scroll

## Future Architecture Plans

### Phase 3: Real ML Integration
- Python backend service (FastAPI)
- WebSocket communication for real-time model results
- Actual sklearn model training and prediction

### Phase 4: Multiplayer
- Dedicated server architecture
- Shared log stream
- Collaborative tool usage

### Phase 5: VR Support
- 3D log visualization
- Spatial tool palette
- Gesture-based tool deployment
