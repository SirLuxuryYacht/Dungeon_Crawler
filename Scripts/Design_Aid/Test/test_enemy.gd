extends CharacterBody3D

var enemy_name = "test_enemy"

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var HitBox = $HitBox
@onready var WeaponParent = $RightHand/TestSword
@onready var Weapon = WeaponParent.get_child(0)

var health = 500

var resistance = [1,1,1,1]

var coin_drop_base = 500

var coin_error = coin_drop_base / 4 

############ behavior variables
var decide_timer = 0

var decide_time = randf_range(4,6)

var attack_decider = false

var attack_timer = 0

var attack_time = 1

var attack_type = "light"
############

#enemy attack behavior via animations. A pivot bone handles the weapon


func getHealth() -> float:
	return health


func setHealth(value: float) -> void:
	if value <= 0:
		health = 0
	else:
		health = value


func testAI(delta) -> void:
	decide_timer += delta
	if decide_timer > decide_time:
		decide_time = 4#randf_range(4,6)
		decide_timer = 0


func attack(delta) -> void: #this is just the player attack, without any movement of the weapon, only the hitting and hurting
	if decide_timer == 0 and !WeaponParent.attacking:
		WeaponParent.attacking = true
		WeaponParent.get_hurt_box().set("disabled", false)
	if decide_timer > 0.25 * decide_time and WeaponParent.attacking:
		WeaponParent.attacking = false
		WeaponParent.get_hurt_box().set("disabled", true)
	if !WeaponParent.attacking:
		WeaponParent.store_collision = []
		


func _on_hit_box_area_entered(area: Area3D) -> void:
	var hitter_parent = area.get_parent()
	if "area_type" in hitter_parent:
		if hitter_parent.area_type == "hurt_box": #prevents hitboxes to be detected as sources of damage (only hurtboxes allowed). get_parent because the area is the weapon area3d and not the node controlling the variabless
			if !(HitBox in hitter_parent.store_collision): #prevents the hurtbox from hitting twice if it is left during a single attack
				Signals.take_damage.emit(area,self)


func _ready() -> void:
	Weapon.set_collision_layer_value(4,true) #needed because the test sword is the same
	Weapon.set_collision_mask_value(4,true)
	WeaponParent.damage = WeaponParent.light_damage
	WeaponParent.get_hurt_box().set_deferred("disabled",true)


func _physics_process(delta: float) -> void:
	#Gameplay.generalizedDamager(HitBox,self)
	testAI(delta)
	attack(delta)
	
	if health <= 0:
		Gameplay.spawnCoin(position,Gameplay.coinCalculator(coin_drop_base,coin_error))
		self.queue_free()
