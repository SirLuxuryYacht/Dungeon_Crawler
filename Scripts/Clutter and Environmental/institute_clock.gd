extends StaticBody3D

@onready var Hour = $HourHand
@onready var Minute = $MinuteHand

@onready var times
@onready var current_hour = 0
@onready var current_minute = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	times  = Time.get_datetime_dict_from_system()
	if times["hour"] > 12:
		current_hour = times["hour"] - 12
	else:
		current_hour = times["hour"]
	current_minute = times["minute"]
	Hour.rotation.y = -float(current_hour) * deg_to_rad(30)
	Minute.rotation.y = -float(current_minute) * deg_to_rad(6)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	_ready()
