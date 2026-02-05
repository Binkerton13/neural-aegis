extends AcceptDialog
## Interactive configuration dialog for snare deployment

@onready var target_option: OptionButton = $VBoxContainer/TargetContainer/TargetOption
@onready var location_option: OptionButton = $VBoxContainer/LocationContainer/LocationOption
@onready var trigger_option: OptionButton = $VBoxContainer/TriggerContainer/TriggerOption

var config: Dictionary = {}

signal configuration_confirmed(config: Dictionary)

func _ready():
	confirmed.connect(_on_confirmed)
	setup_options()

func setup_options():
	# Setup target options
	if target_option:
		target_option.clear()
		target_option.add_item(ThemeManager.get_term("threat_actor_plural").capitalize())
		target_option.add_item(ThemeManager.get_term("secondary_threat_plural").capitalize())
		target_option.add_item("All Threats")
	
	# Setup location options
	if location_option:
		location_option.clear()
		location_option.add_item("Network Pathway A")
		location_option.add_item("Network Pathway B")
		location_option.add_item("Specific Location")
		location_option.add_item("All Pathways")
	
	# Setup trigger conditions
	if trigger_option:
		trigger_option.clear()
		trigger_option.add_item("On Access Attempt")
		trigger_option.add_item("On Data Exfiltration")
		trigger_option.add_item("On Unusual Activity")
		trigger_option.add_item("Immediate")

func _on_confirmed():
	config = {
		"target": target_option.get_item_text(target_option.selected) if target_option else "Unknown",
		"location": location_option.get_item_text(location_option.selected) if location_option else "Unknown",
		"trigger": trigger_option.get_item_text(trigger_option.selected) if trigger_option else "Immediate"
	}
	configuration_confirmed.emit(config)

func show_dialog():
	popup_centered()
