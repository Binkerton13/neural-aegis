extends Node
## Global theme manager that handles theme switching and translation of game terminology
## AutoLoad singleton that provides theme-specific terminology throughout the game

var themes: Dictionary = {}
var current_theme: String = "forest"

signal theme_changed(new_theme: String)

func _ready():
	load_themes()

## Load themes from the JSON configuration file
func load_themes():
	var file_path = "res://data/themes.json"
	
	if not FileAccess.file_exists(file_path):
		push_error("Themes file not found: " + file_path)
		# Provide fallback default theme
		themes = {
			"forest": {
				"name": "Forest Critters",
				"threat_actor": "fox",
				"normal_entity": "squirrel",
				"resource": "squirrel egg",
				"location": "den"
			}
		}
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("Failed to parse themes.json: " + json.get_error_message())
		return
	
	themes = json.data
	print("Loaded ", themes.size(), " themes: ", themes.keys())

## Get a translated term for the current theme
## @param key: The key to look up (e.g., "threat_actor", "resource")
## @return: The themed term, or the key itself if not found
func get_term(key: String) -> String:
	if not themes.has(current_theme):
		push_warning("Theme not found: " + current_theme)
		return key
	
	var theme_data = themes[current_theme]
	if theme_data.has(key):
		return theme_data[key]
	else:
		push_warning("Key '" + key + "' not found in theme '" + current_theme + "'")
		return key

## Switch to a different theme
## @param theme_name: Name of the theme to switch to
func switch_theme(theme_name: String):
	if not themes.has(theme_name):
		push_error("Cannot switch to unknown theme: " + theme_name)
		return
	
	current_theme = theme_name
	print("Switched to theme: ", themes[theme_name]["name"])
	theme_changed.emit(theme_name)

## Get list of all available theme names
## @return: Array of theme keys (e.g., ["forest", "cyber", "fantasy"])
func get_available_themes() -> Array:
	return themes.keys()

## Get display name of a theme
## @param theme_name: The theme key
## @return: The display name of the theme
func get_theme_display_name(theme_name: String) -> String:
	if themes.has(theme_name) and themes[theme_name].has("name"):
		return themes[theme_name]["name"]
	return theme_name

## Get the current theme's display name
func get_current_theme_name() -> String:
	return get_theme_display_name(current_theme)
