extends Control

@onready var OverlayAnimations = $OverlayAnimations
@onready var UnderWater = $UnderWater



func addOrRemoveOverlay(mode: String, overlay_type: String) -> void:
	OverlayAnimations.play(overlay_type+"_"+mode)
