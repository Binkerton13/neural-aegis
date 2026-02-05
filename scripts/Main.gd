extends Node
## Main scene controller
## Initializes the game and loads the main dashboard

func _ready():
	print("=== Neural Aegis Starting ===")
	print("Theme Manager: ", ThemeManager.get_current_theme_name())
	print("Available themes: ", ThemeManager.get_available_themes())
	
	# Load the main dashboard scene
	var main_dashboard = load("res://scenes/MainDashboard.tscn")
	if main_dashboard:
		var dashboard_instance = main_dashboard.instantiate()
		add_child(dashboard_instance)
	else:
		push_error("Failed to load MainDashboard.tscn")
