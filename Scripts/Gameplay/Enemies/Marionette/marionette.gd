extends CharacterBody3D

var id: int

var type = "NPC"

var enemy_name = "marionette"

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var Strings = $Strings
@onready var Action = $Action
@onready var AttackOnset = $AttackOnset
@onready var WeaponParent = $RightHand/Weapon
@onready var Weapon = $RightHand/Weapon/Weapon
@onready var HurtBox = $RightHand/Weapon/Weapon/CollisionShape3D
@onready var HitBox = $FakeHitBox
@onready var _AnimationPlayer = $puppet1/AnimationPlayer
@onready var Collision = $CollisionShape3D
@onready var RightHandBone = $puppet1/Armature/Skeleton3D/RightHandBone
@onready var RightFootBone = $puppet1/Armature/Skeleton3D/RightFootBone
@onready var RightHand = $RightHand
var ActiveBone = RightHandBone

var spawn_position = position
var passive = true
var has_attacked = false
var has_died = false

var health = 500

var coin_drop_base = 120

var coin_error = 20

var experience = 354

var resistance = [-1,1,-1,-1]

const idle_time = 2
const attack_time = 2
const hit_time = 2
const float_forward_time = 2
const float_back_time = 2
const death_time = 2

var next_action = "idle"

const attack_distance = 1.5

func _ready() -> void:
	spawn_position = position


func stringFacer() -> void:
	var distance_to_player = distanceToPlayer()
	Strings.global_rotation.y = atan2(distance_to_player.x,distance_to_player.z)


func timeSetter(action) -> void:
	Action.set_wait_time(get(action+"_time"))


func turnToPlayer() -> void:
	var distance_to_player = distanceToPlayer()
	rotation.y = atan2(distance_to_player.x,distance_to_player.z) - PI / 2
	
func playerInReach() -> bool:
	var in_reach = false
	if distanceToPlayer().length() < attack_distance and abs(distanceToPlayer().dot(Vector3(0,0,1).rotated(Vector3.UP,rotation.y))) < PI / 6:
		in_reach = true
	return in_reach

func passiveMovement() -> void:
	_AnimationPlayer.play("Idle")


func activeMovement() -> void:
	pass

func distanceToPlayer() -> Vector3:
	return Gameplay.getPlayerPosition() - position


func _physics_process(_delta: float) -> void:
	
	if health <= 0 and !has_died:
		has_died = true
	
	if has_died and next_action != "death":
		velocity = Vector3.ZERO
		Collision.set("disabled",true)
		if HurtBox.disabled == false:
			HurtBox.set_deferred("disabled",true)
		next_action = "death"
		Action.start()
		_AnimationPlayer.stop() #does the animation player need to stop to immediately start the next animation?
		_AnimationPlayer.play("Death")
	elif playerInReach() and velocity.length() < 0.1 and !has_attacked:
		has_attacked = true
		AttackOnset.start()
		next_action = "attack"
		Action.start()
		velocity = Vector3.ZERO
		var i = randi_range(0,1)
		if i == 0:
			_AnimationPlayer.stop()
			_AnimationPlayer.play("Attack1")
			ActiveBone = RightHandBone
		if i == 1:
			_AnimationPlayer.stop()
			_AnimationPlayer.play("Attack2")
			ActiveBone = RightFootBone
		turnToPlayer()
		
	if !HurtBox.disabled:
		RightHand.global_position = ActiveBone.global_position
	
	stringFacer()
	move_and_slide()
	

func actionDecider() -> void:
	velocity = Vector3.ZERO
	var distance_to_player = distanceToPlayer()
	if next_action == "attack":
		next_action = "float_back"
		_AnimationPlayer.stop()
		_AnimationPlayer.play("Float")
		turnToPlayer()
		velocity = - 1.5 * Vector3(distance_to_player.x,0,distance_to_player.z).normalized()
	
	elif next_action == "float_back":
		next_action = "idle"
		velocity = Vector3.ZERO
		_AnimationPlayer.stop()
		_AnimationPlayer.play("Idle")
	
	elif distance_to_player.length() >= attack_distance and (next_action == "idle" or next_action == "float_forward"):
		var i = randf_range(0,1)
		if i > 0.5:
			next_action = "idle"
			velocity = Vector3.ZERO
			_AnimationPlayer.stop()
			_AnimationPlayer.play("Idle")
		else:
			next_action = "float_forward"
			_AnimationPlayer.stop()
			_AnimationPlayer.play("Float")
			turnToPlayer()
			velocity = 1.5 * Vector3(distance_to_player.x,0,distance_to_player.z).normalized()


func _on_action_timeout() -> void:
	if has_attacked:
		has_attacked = false
	if !passive:
		actionDecider()
	else:
		passiveMovement()
	timeSetter(next_action)
	Action.start()
	if HurtBox.disabled == false:
		HurtBox.set_deferred("disabled",true)
	if has_died:
		CombatFunctions.addKillExperience(Gameplay,experience)
		self.queue_free()
		Gameplay.spawnCoin(position,Gameplay.coinCalculator(coin_drop_base,coin_error))
	

func _on_player_detector_body_entered(_body: Node3D) -> void:
	passive = false
	timeSetter("idle")
	Action.start()


func _on_player_detector_body_exited(_body: Node3D) -> void:
	passive = true
	_AnimationPlayer.play("Idle")


func _on_attack_onset_timeout() -> void:
	WeaponParent.store_collision = []
	HurtBox.set_deferred("disabled",false)


func _on_hit_box_area_entered(_area: Area3D) -> void:
	Collision.set_deferred("disabled",true)
	HurtBox.set_deferred("disabled",true)
	_AnimationPlayer.stop()
	_AnimationPlayer.play("Death")
	next_action = "death"
	has_died = true


func _on_fake_hit_box_area_entered(area: Area3D) -> void:
	if !has_died:
		HurtBox.set_deferred("disabled",true)
		_AnimationPlayer.stop()
		_AnimationPlayer.play("Hit")
		AttackOnset.stop()
		next_action = "hit"
		
	var hitter_parent = area.get_parent()
	if "area_type" in hitter_parent:
		if hitter_parent.area_type == "hurt_box": #prevents hitboxes to be detected as sources of damage (only hurtboxes allowed). get_parent because the area is the weapon area3d and not the node controlling the variabless
			if !(HitBox in hitter_parent.store_collision): #prevents the hurtbox from hitting twice if it is left during a single attack
				Signals.take_damage.emit(area,self)
				hitter_parent.store_collision.append(HitBox)
