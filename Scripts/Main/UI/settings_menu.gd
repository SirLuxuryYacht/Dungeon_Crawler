extends Control

@onready var Main = get_tree().root.get_node("Main") #reference to root node of game
@onready var GameStateParent = Main.get_child(0) #decides if this menu was opened from "gameplay" or "main_menu"
@onready var ExitSettingsButton = $ExitSettingsButton
@onready var DisplayMode = $DisplayMode
@onready var SettingsMenuHandler = GameStateParent.get_node("SettingsMenuHandler")
@onready var LookSensitivityLabel = $LookSensitivityLabel
@onready var LookSensitivitySlider = $LookSensitivitySlider
@onready var LookSensitivityNumberLabel = $LookSensitivityNumberLabel
@onready var SettingsHandlerColorRect = $SettingsHandlerColorRect


func saveSettings() -> void:
	var settings_file
	if OS.get_name() == "Windows" or OS.get_name() == "UWP":
		settings_file = FileAccess.open("C://Users/Olai/Desktop/save_test/settings.dat", FileAccess.WRITE)
	if OS.get_name() == "Linux":
		settings_file = FileAccess.open("/home/olai/Desktop/saves/settings.dat", FileAccess.WRITE)
	settings_file.store_var(LookSensitivitySlider.value) #stores the look sensitivity


func updateDisplayMode() -> void:
	var display_mode = DisplayMode.text
	if display_mode == "Fullscreen":
		DisplayServer.window_set_size(DisplayServer.screen_get_size())
	if display_mode == "Windowed":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func quitSettingsMenu() -> void:
	#if GameStateParent.get_name() == "Gameplay":
		#GameStateParent.get_node("PauseMenuHandler").get_node("PauseMenu").ProcessMode.PROCESS_MODE_INHERIT #continues processing in previously halted pause menu node in "gameplay"
	get_parent().visible = false
	self.queue_free()


func displayModeText() -> void:
	DisplayMode.text = DisplayMode.get_item_text(DisplayMode.get_selected_id())



func changeCameraSensitivity() -> void:
	if LookSensitivitySlider.value == 0:
		LookSensitivitySlider.value = 1
	if LookSensitivityNumberLabel.text != str(LookSensitivitySlider.value):
		LookSensitivityNumberLabel.text = str(int(LookSensitivitySlider.value))


func writeSettingChangesOnExit() -> void:
	if ExitSettingsButton.button_pressed or Input.is_action_just_pressed("pause"):
		Main.camera_sensitivity = LookSensitivitySlider.value
		if Main.has_node("Gameplay"):
			Main.get_node("Gameplay").getPlayer().camera_sensitivity = LookSensitivitySlider.value
		#Gameplay.getPlayer().camera_sensitivity = LookSensitivitySlider.value
		saveSettings()
		quitSettingsMenu()


func _ready() -> void:
	DisplayMode.text = Main.display_mode
	DisplayMode.select(0)
	LookSensitivitySlider.value = Main.camera_sensitivity
	SettingsHandlerColorRect.visible = false


func _input(event: InputEvent) -> void:
	changeCameraSensitivity()
	writeSettingChangesOnExit()


func _on_controls_button_up() -> void:
	SettingsHandlerColorRect.visible = true


func _on_return_from_controls_button_up() -> void:
	SettingsHandlerColorRect.visible = false
