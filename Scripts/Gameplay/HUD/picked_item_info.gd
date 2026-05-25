extends Control

@export var static_time: float
@export var fade_time: float

@export var fade_distance: float

@onready var RemoveTimer = $RemoveTimer
@onready var BackgroundTexture = $BackgroundTexture
@onready var ItemName = $BackgroundTexture/ItemName
@onready var ItemPicture = $BackgroundTexture/ItemPicture

var elapsed_time = 0
var item_name = "Placeholder"

var item_texture_path = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if static_time + fade_time > 0.075:
		RemoveTimer.start(static_time + fade_time)
	else:
		RemoveTimer.start()
	ItemPicture.texture = load(item_texture_path)
	ItemName.text = item_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time > static_time:
		BackgroundTexture.anchor_bottom -= 0.03 * delta
		BackgroundTexture.modulate.a = 1-(elapsed_time - static_time)/fade_time



func _on_remove_timer_timeout() -> void:
	self.queue_free()
