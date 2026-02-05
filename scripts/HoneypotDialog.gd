extends AcceptDialog
## Interactive configuration dialog for honeypot deployment

@onready var location_option: OptionButton = $VBoxContainer/LocationContainer/LocationOption
@onready var payload_option: OptionButton = $VBoxContainer/PayloadContainer/PayloadOption
@onready var bait_edit: LineEdit = $VBoxContainer/BaitContainer/BaitEdit

var config: Dictionary = {}

signal configuration_confirmed(config: Dictionary)

func _ready():
	confirmed.connect(_on_confirmed)
	setup_options()

func setup_options():
	# Setup location options
	if location_option:
		location_option.clear()
		location_option.add_item("Entity Location #1")
		location_option.add_item("Entity Location #5")
		location_option.add_item("Entity Location #10")
		location_option.add_item("Random Location")
	
	# Setup payload options
	if payload_option:
		payload_option.clear()
		payload_option.add_item("High Value Data")
		payload_option.add_item("Credentials")
		payload_option.add_item("System Access")
		payload_option.add_item("Custom")

func _on_confirmed():
	config = {
		"location": location_option.get_item_text(location_option.selected) if location_option else "Unknown",
		"payload": payload_option.get_item_text(payload_option.selected) if payload_option else "Unknown",
		"bait": bait_edit.text if bait_edit else ThemeManager.get_term("honeypot_bait")
	}
	configuration_confirmed.emit(config)

func show_dialog():
	popup_centered()
