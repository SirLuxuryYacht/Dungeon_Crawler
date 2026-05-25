extends Control

var node_name = "MainMenu"

@onready var Continue = $Continue
@onready var LoadGame = $LoadGame
@onready var Settings = $Settings
@onready var Quit = $Quit
@onready var LoadMenuHandler = $LoadMenuHandler
@onready var SettingsMenuHandler = $SettingsMenuHandler
@onready var GameDeathObfuscator = $GameDeathObfuscator
var Main = null

var from_death = false

func _ready() -> void:
	#GameDeathObfuscator.visible = true
	SettingsMenuHandler.visible = false
	Main = get_tree().root.get_node("Main")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	for i in 3:
		var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		
		if !DirAccess.dir_exists_absolute(desktop_path.path_join("save_test")):
			DirAccess.make_dir_recursive_absolute(desktop_path.path_join("save_test"))
		
		var save_file_path = desktop_path.path_join("save_test/save_game_"+str(i+1)+".dat")
		
		if FileAccess.file_exists(save_file_path):
			Continue.text = "Continue"


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Quit.button_pressed:
			get_tree().quit()
		if Settings.button_pressed:
			get_node("SettingsMenuHandler").add_child(load("res://Scenes/UI/settings_menu.tscn").instantiate())
			SettingsMenuHandler.visible = true
		if LoadGame.button_pressed:
			get_node("LoadMenuHandler").add_child(load("res://Scenes/LoadGameScreen/load_game_screen.tscn").instantiate())
			LoadMenuHandler.visible = true
		if Continue.button_pressed:
			Main.startGame("")
