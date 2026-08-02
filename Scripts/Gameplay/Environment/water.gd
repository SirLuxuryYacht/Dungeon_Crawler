extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_deep_water_body_entered(body: Node3D) -> void:
	if "in_water" in body:
		body.in_water = true
		CombatFunctions.doDrowning(true,body)
		if body.name == "Player":
			body.get_node("OverlayEffects").addOrRemoveOverlay("add","under_water")


func _on_deep_water_body_exited(body: Node3D) -> void:
	if "in_water" in body:
		body.in_water = false
		CombatFunctions.doDrowning(false,body)
		if body.name == "Player":
			body.get_node("OverlayEffects").addOrRemoveOverlay("remove","under_water")
