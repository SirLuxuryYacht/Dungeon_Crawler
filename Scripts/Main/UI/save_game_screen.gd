extends Control

@onready var Main = get_tree().root.get_node("Main")
@onready var Gameplay = Main.get_node("Gameplay")

@onready var File1 = $File1
@onready var File2 = $File2
@onready var File3 = $File3

@onready var SaveOverlay = $SaveOverlay

@onready var GameSaved = $GameSaved

var selected_save = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSaved.visible = false
	writeSaveGame()


func writeSaveGame() -> void:
	for i in 3:
		
		var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		
		if !DirAccess.dir_exists_absolute(desktop_path.path_join("save_test")):
			DirAccess.make_dir_recursive_absolute(desktop_path.path_join("save_test"))
		
		var save_file_path = desktop_path.path_join("save_test/save_game_"+str(i+1)+".dat")
		
		if FileAccess.file_exists(save_file_path):
			var file = FileAccess.open(save_file_path, FileAccess.READ)
			var button = get_node("File"+str(i+1))
			button.text = "Savefile "+str(i+1)
			button.disabled = false
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	SaveOverlay.visible = false
	selected_save = 0


func _on_confirm_pressed() -> void:
	if selected_save > 0:
		Gameplay.saveGame(selected_save)
		SaveOverlay.visible = false
		GameSaved.visible = true
		$Timer.start()
		$GameSavedAnimation.play("GameSavedSlideAndFade")
		writeSaveGame()


func _on_file_1_pressed() -> void:
	SaveOverlay.visible = true
	selected_save = 1


func _on_file_2_pressed() -> void:
	SaveOverlay.visible = true
	selected_save = 2


func _on_file_3_pressed() -> void:
	SaveOverlay.visible = true
	selected_save = 3


func _on_return_pressed() -> void:
	get_parent().visible = false
	self.queue_free()


func _on_timer_timeout() -> void:
	GameSaved.visible = false
