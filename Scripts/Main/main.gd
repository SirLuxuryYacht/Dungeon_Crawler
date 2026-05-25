extends Node

var selected_file = 1

var game_resolution

var display_mode = "Fullscreen"

################# settings variables
var camera_sensitivity = 15 #initial camera sensitivity upon first startup of the game and if no save file is available
#################


func loadSettings() -> void:
	var settings_file
	if OS.get_name() == "Windows" or OS.get_name() == "UWP":
		settings_file = FileAccess.open("C://Users/Olai/Desktop/save_test/settings.dat", FileAccess.READ)
	if OS.get_name() == "Linux":
		settings_file = FileAccess.open("/home/olai/Desktop/saves/settings.dat", FileAccess.READ)
	if settings_file != null:
		camera_sensitivity = settings_file.get_var()


func loadLastSaveSelector() -> void:
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		
	if !DirAccess.dir_exists_absolute(desktop_path.path_join("save_test")):
		DirAccess.make_dir_recursive_absolute(desktop_path.path_join("save_test"))
		
	var main_info_file_path = desktop_path.path_join("save_test/main_info_file.dat")
		
	if FileAccess.file_exists(main_info_file_path):
		selected_file = FileAccess.open(main_info_file_path,FileAccess.READ).get_var()


func startGame(from_where) -> void:
	if from_where == "from_death":
		if get_child_count() != 0 and get_child(0).name == "Gameplay":
			var deleted = get_node("Gameplay")
			remove_child(deleted) #remove_child() instead of queue_free() works better
			add_child(load("res://Scenes/Gameplay/gameplay.tscn").instantiate())
			deleted.queue_free()
	else:
		if get_child_count() != 0 and get_child(0).name == "MainMenu":
			get_node("MainMenu").queue_free()
			add_child(load("res://Scenes/Gameplay/gameplay.tscn").instantiate())


func deleteFile(selected_file_) -> void:
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		
	if !DirAccess.dir_exists_absolute(desktop_path.path_join("save_test")):
		DirAccess.make_dir_recursive_absolute(desktop_path.path_join("save_test"))
		
	var save_file_path = desktop_path.path_join("save_test/save_game_"+str(selected_file_)+".dat")
		
	if FileAccess.file_exists(save_file_path):
		DirAccess.remove_absolute(save_file_path)


func returnToMainMenu(from_where) -> void:
	get_tree().paused = false
	if get_child_count() != 0 and get_child(0).name == "Gameplay":
		get_node("Gameplay").queue_free()
		add_child(load("res://Scenes/Main_Menu/main_menu.tscn").instantiate())
		var MainMenu = get_node("MainMenu")
		if from_where == "from_death":
			MainMenu.from_death = true


func _ready() -> void:
	var MainMenu = load("res://Scenes/Main_Menu/main_menu.tscn").instantiate()
	add_child(MainMenu)
	loadSettings()
	loadLastSaveSelector()
