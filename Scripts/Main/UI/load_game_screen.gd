extends Control

@onready var Main = get_tree().root.get_node("Main")

@onready var SelectedFileNumber = $SelectedFileNumber

@onready var File1 = $File1
@onready var File2 = $File2
@onready var File3 = $File3

@onready var LoadFile = $LoadFile
@onready var DeleteFile = $DeleteFile

@onready var DeleteConfirmer = $DeleteConfirmer

func _ready() -> void:
	writeSaveGame()


func writeSaveGame() -> void:
	SelectedFileNumber.text = "No file selected"
	
	for i in 3:
		
		var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		
		if !DirAccess.dir_exists_absolute(desktop_path.path_join("save_test")):
			DirAccess.make_dir_recursive_absolute(desktop_path.path_join("save_test"))
		
		var save_file_path = desktop_path.path_join("save_test/save_game_"+str(i+1)+".dat")
		
		if FileAccess.file_exists(save_file_path):
			var file = FileAccess.open(save_file_path,FileAccess.READ)
			
			var button = get_node("File"+str(i+1))
			button.text = "Savefile "+str(i+1)
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			var player_level = file.get_var()
			var player_xp = file.get_var()
			var physical_level = file.get_var()
			var magic_level = file.get_var()
			var loaded_map = file.get_var()
			for j in button.get_child_count():
				button.get_child(j).visible = true
			button.get_node("LevelAmount").text = str(player_level)
			button.get_node("ExpAmount").text = str(player_xp)
			button.get_node("PhysAmount").text = str(physical_level)
			button.get_node("MagAmount").text = str(magic_level)
			button.get_node("Map").text = Designators.represent("map",loaded_map)
		else:
			var button = get_node("File"+str(i+1))
			button.text = "Empty"
			button.alignment = HORIZONTAL_ALIGNMENT_CENTER
			for j in button.get_child_count():
				button.get_child(j).visible = false


func _on_file_1_pressed() -> void:
	Main.selected_file = 1
	SelectedFileNumber.text = str(1)
	LoadFile.disabled = false
	showHideDelete(File1)

func _on_file_2_pressed() -> void:
	Main.selected_file = 2
	SelectedFileNumber.text = str(2)
	LoadFile.disabled = false
	showHideDelete(File2)

func _on_file_3_pressed() -> void:
	Main.selected_file = 3
	SelectedFileNumber.text = str(3)
	LoadFile.disabled = false
	showHideDelete(File3)

func _on_load_file_pressed() -> void:
	
	if Main.get_child(0).node_name == "Gameplay":
		Main.startGame("from_death")
	else:
		Main.startGame("")


func showHideDelete(FileButton) -> void:
	if FileButton.text == "Empty":
		DeleteFile.disabled = true
	else:
		DeleteFile.disabled = false


func _on_return_pressed() -> void:
	if Main.get_child(0).node_name == "MainMenu": 
		get_parent().visible = false
	self.queue_free()


func _on_delete_file_pressed() -> void:
	DeleteConfirmer.visible = true
	


func _on_confirm_pressed() -> void:
	Main.deleteFile(Main.selected_file)
	writeSaveGame()
	DeleteConfirmer.visible = false


func _on_back_pressed() -> void:
	DeleteConfirmer.visible = false
