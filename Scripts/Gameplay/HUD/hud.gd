extends Control

@onready var Health = $HealthStaminaMagic/Health
@onready var Stamina = $HealthStaminaMagic/Stamina
@onready var EquippedWeaponLabel = $EquippedWeapon/EquippedWeaponLabel
@onready var EquippedUsableLabel = $EquippedUsable/EquippedUsableLabel
@onready var UsableAmountLabel = $EquippedUsable/UsableAmountLabel

func _physics_process(delta: float) -> void:
	Health.size.x += -15 * delta * (Health.size.x - get_parent().getHealth())
	Stamina.size.x += -20 * delta * (Stamina.size.x - get_parent().getStamina())


func getUsableLabel() -> Label:
	return EquippedUsableLabel


func getWeaponLabel() -> Label:
	return EquippedWeaponLabel
	

func getUsableAmountLabel() -> Label:
	return UsableAmountLabel
