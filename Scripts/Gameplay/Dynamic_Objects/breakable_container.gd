extends Node3D

var item_name = "barrel"

var content = "test_sword" #this is governed by a script

var coin_amount = 50 #tis is governed by a script

var id: int = 0

var type = "container"

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var Model = $Model
@onready var HitBox = $HitBox
@onready var _AnimationPlayer = $Model/AnimationPlayer
@onready var BreakSound = $BreakSound

@export var robustness = 45

var health = robustness

@export var resistance = [1,1,1,1]


func setContent(desired_content) -> void:
	if desired_content is Array:
		content = desired_content[0]
		coin_amount = desired_content[1]
	else:
		content = desired_content


func _ready() -> void:
	ParameterFunctions.applyShaderParameters("container",self,Gameplay.getCurrentMap().map_brightness)
	if Gameplay.isContainerOpened(self):
		disableCollisionAndBreak(false)


func disableCollisionAndBreak(with_sound: bool) -> void:
	for i in HitBox.get_child_count():
		HitBox.get_child(i).set_deferred("disabled",true)
		Model.get_child(i+1).set_deferred("disabled",true)
		$Model/AnimationPlayer.play("break")
	if with_sound:
		BreakSound.play()


func _on_hit_box_area_entered(area: Area3D) -> void:
	if area.name == "DarknessBox":
		ParameterFunctions.applyShaderParameters("container",self,0.0)
	if "area_type" in area.get_parent():
		if area.get_parent().area_type == "hurt_box": #prevents hitboxes from being detected as sources of damage (only hurtboxes allowed). get_parent because the area is the weapon area3d and not the node controlling the variabless
			Signals.take_damage.emit(area,self)
			if health > 0:
				health = robustness
			else:
				Gameplay.storeContainerOpening(self)
				disableCollisionAndBreak(true)
				if content == "coin":
					Gameplay.spawnCoin(position+Vector3(0,1,0),coin_amount)
				else:
					Gameplay.spawnItem(position+Vector3(0,1,0),content,false,0) #spawns the content at the position of the container. the content is not permanent, thus false is given to spawnItem()
