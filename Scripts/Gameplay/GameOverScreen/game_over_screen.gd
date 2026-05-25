extends Control

@onready var Main = get_tree().root.get_node("Main")
@onready var Gameplay = Main.get_node("Gameplay")
@onready var LoadLastSaveButton = $LoadLastSaveButton
@onready var MainMenuButton = $MainMenuButton


func _process(delta: float) -> void:
	if LoadLastSaveButton.button_pressed:
		self.add_child(load("res://Scenes/LoadGameScreen/load_game_screen.tscn").instantiate())
	if MainMenuButton.button_pressed:
		Gameplay.get_node("GameOverScreenHandler").get_child(0).queue_free()
		Main.returnToMainMenu("")
