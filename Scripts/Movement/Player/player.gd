extends CharacterBody3D

@onready var Camera = $Camera
@onready var UpperBodyCollision = $UpperBodyCollision
@onready var LowerBodyCollision = $LowerBodyCollision
@onready var GroundDetector = $LowerBodyCollision/GroundDetector
@onready var StepSound = $FootstepSoundsDirt
@onready var CeilingDetector = $UpperBodyCollision/CeilingDetector
@onready var InteractionRay = $Camera/InteractionRay
@onready var Main = get_tree().root.get_node("Main")
@onready var Gameplay = Main.get_node("Gameplay")
@onready var RightHand = $RightHand
@onready var ItemSounds = $ItemSounds
@onready var HitBox = $HitBox
@onready var HitBoxUpper = HitBox.get_node("HitBoxUpper")
@onready var HitBoxLower = HitBox.get_node("HitBoxLower")
@onready var PickedItemInfo = $GameplayPromptHandler/PickedItemInfo

@onready var WeaponParent = null #the parent node of the area3d node of the weapon, used for pivoting and inert movement
@onready var Weapon = null #the area3d node of the weapon 
@onready var ChargeHeavy = $Timers/ChargeHeavy
@onready var AttackTimer = $Timers/AttackTimer
@onready var AttackBlocker = $Timers/AttackBlocker

@onready var GameplayPromptHandler = $GameplayPromptHandler
@onready var PickUpPrompt = GameplayPromptHandler.get_node("PickUpPrompt")
@onready var TalkPrompt = GameplayPromptHandler.get_node("TalkPrompt")
@onready var Hud = $Hud
#@onready var Health = Hud.get_node("HealthStaminaMagic/Health")
@onready var Stamina = Hud.get_node("HealthStaminaMagic/Stamina")
@onready var PickUpInfoHandler = Hud.get_node("PickUpInfoHandler")

@onready var Torch = $Camera/Torch

var crouching = false

const lower_body_default_position = 0.5
const upper_body_default_position = 1.3

@onready var lower_body_dynamic_position = lower_body_default_position
@onready var upper_body_dynamic_position = upper_body_default_position

func crouchUpdater(is_crouching: bool) -> void:
	if is_crouching:
		lower_body_dynamic_position = lower_body_default_position + 0.5
		upper_body_dynamic_position = upper_body_default_position - 0.5
	else:
		lower_body_dynamic_position = lower_body_default_position
		upper_body_dynamic_position = upper_body_default_position


func crouchPositioning(delta) -> void:
	LowerBodyCollision.position.y += -15 * delta * (LowerBodyCollision.position.y - lower_body_dynamic_position)
	UpperBodyCollision.position.y += -15 * delta * (UpperBodyCollision.position.y - upper_body_dynamic_position + cameraBob(velocity.length(),delta))


func getTorch() -> Node3D:
	return Torch


func playItemSound(sound: String) -> void:
	ItemSounds.stream = load("res://Sounds/Player/ItemSounds/"+sound+".ogg")
	ItemSounds.pitch_scale = randf_range(0.95,1.05)
	ItemSounds.play()


var run_allowed = true
var stamina_max = 429 #size gotten from the control node
var health_max = 429
var stamina = 429

var body_type = "softbody"

var recovery_inhibition = 1 #the default stamina recovery speed factor, used in gameplay.staminarecovery

var voided = false #has the player fallen into a void? then they should not fall any further

var in_water = false
var water_speed = 1.5
var dry_speed = 3 #default 3

var gravity = Vector3(0,-9.81,0) #outsource to gameplay node

var resistance_factor = 20

var air_resistance = 0.000

var mass = 80

var camera_speed = 0.0001 * Vector2.ONE

var camera_sensitivity = 1

var walk_speed  = dry_speed

@export var run_multiplier = 1.33 #default 1.33

var crouch_speed = 0.5

var mass_inert_velocity = Vector3.ZERO

var bob_cycle = 0

var bob_height = 0

var right_hand_offset = Vector3(-0.25,-0.2,-0.25)

var left_hand_offset = Vector3(0.2,0,0)

var weapon_inertia = 15

var has_stepped = false

var frame_counter = 0

var mouse_distance = Vector2.ZERO

var latent_mouse_distance = Vector2.ZERO

var vertical_cam_factor = 2 #factor for aesthetic reasons, gets set to 1 if one attacks with a weapon

var equipped_weapons = ["unarmed","unarmed","unarmed"]

var weapon_in_hand = "unarmed"

var usable_in_hand = "none"

var weapon_selector = 0

var usable_selector = 0

var jump_coefficient = 250

var airborne = false

var fall_damage = 0

var impact = 0

var dying_duration = 1

var dying_duration_timer = 0

var dead = false

var strength = 1 #increases down stamina replenishment

var weight = 1 #slows down stamina replenishment

############################## weapon and attack variables
var make_weapon_ready = false

var attacking = false

var attack_over = false

var light_chain = 1

var heavy_chain = 1

var attack_type = "light"

var attack_timer = 0

var attack_duration = 0

var heavy_ready_time = 0 #the time it takes for heavy attacks to prepare

var heavy_ready_timer = 0

var attack_pos_1 = Vector3.ZERO

var attack_pos_2 = Vector3.ZERO

var attack_rot_1 = Vector3.ZERO

var attack_rot_2 = Vector3.ZERO

var attack_state = 1 #one of two attack states for chaining attacks
##############################

############################## damage calculator
var health = 0

var resistance = [1,1,1,1]
##############################

var weight_factor = 0.5

var strength_factor = 0.5

@export var landing_resilience: float = 70

#handles the inputs during active player
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !Input.is_action_pressed("crouch"):
			crouching = false
		else:
			crouching = true
		crouchUpdater(crouching)
		if !attacking:
			chooseWeapon("at_runtime")
			chooseUsable("at_runtime")
			usable_in_hand = Gameplay.equipped_usable
			weapon_in_hand = Gameplay.equipped_weapon
			if weapon_in_hand != "rifle":
				changeFOV(80)
			Gameplay.weapon_selector = weapon_selector
			if Input.is_action_just_pressed("use_item"):
				Gameplay.useItem(usable_in_hand,self)
			#add a function to use the shield, maybe
	if Input.is_action_just_pressed("use"):
		interactionRayDetection()
	if event is InputEventMouseButton:
		if Input.is_action_pressed("right_click"):
			make_weapon_ready = true
		else:
			make_weapon_ready = false
			attack_state = 1
			if !attacking:
				vertical_cam_factor = 2
				recovery_inhibition = 1
	attack()


func showInteractionPrompt(type) -> void:
	if type == "item":
		if PickUpPrompt.visible == false:
			PickUpPrompt.visible = true
	if type == "npc" or type == "merchant":
		if TalkPrompt.visible == false:
			TalkPrompt.visible = true


func closeInteractionPrompt() -> void:
	if PickUpPrompt.visible == true:
		PickUpPrompt.visible = false
	if TalkPrompt.visible == true:
		TalkPrompt.visible = false


func interactionRayDetection() -> void:
	if InteractionRay.is_colliding():
		var Collider = InteractionRay.get_collider()
		if Collider != null:
			var type = Collider.get_parent().type
			if GameplayPromptHandler.visible:
				if type == "item":
					showInteractionPrompt("item")
					if Input.is_action_just_pressed("use"):
						pickUpItem()
				if type == "npc" or type == "merchant":
					showInteractionPrompt("npc")
					if Input.is_action_just_pressed("use"):
						match type:
							"npc":
								Gameplay.openDialogue(Collider.get_parent(),true) #the collider is only the Area3D of the actual node
							"merchant":
								Gameplay.openTradeMenu(Collider.get_parent().character_name,Collider.get_parent())
	else:
		closeInteractionPrompt()


func pickUpItem() -> void:
	var picked_item = InteractionRay.get_collider().get_parent()
	var item_name = picked_item.item_name
	var item_identifier = picked_item.get_child(0).name
	var audio_player = get_node("PickUpSoundPlayer")
	var tree_item = Gameplay.get_node("VirtualSpace/DroppedItems").get_node(picked_item.get_path())
	if item_identifier == "Coin":
		audio_player.stream = load("res://Sounds/Player/ItemSounds/coin_pick_up.ogg")
		audio_player.pitch_scale = randf_range(0.6,1.1)
		audio_player.play()
		var PickUpInfoHandler_ = getPickUpInfoHandler()
		for i in PickUpInfoHandler_.get_child_count():
			PickUpInfoHandler_.remove_child(PickUpInfoHandler_.get_child(0))
		var CoinPickUpInfo = load("res://Scenes/HUD/coin_pick_up_info.tscn").instantiate()
		CoinPickUpInfo.get_node("InfoLabel").text = str(tree_item.amount) #displays the amount of the coins picked up
		PickUpInfoHandler_.add_child(CoinPickUpInfo)
		Gameplay.coin_count += tree_item.amount
	else:
		var ItemPickUpInfo = load("res://Scenes/HUD/picked_item_info_card.tscn").instantiate()
		var item_texture_path
		if ResourceLoader.exists("res://Textures/ItemPictures/"+str(item_name)+".png"):
			item_texture_path = "res://Textures/ItemPictures/"+str(item_name)+".png"
		else:
			item_texture_path = "res://Textures/ItemPictures/placeholder.png"
		ItemPickUpInfo.item_texture_path = item_texture_path
		ItemPickUpInfo.item_name = Designators.represent("item",item_name)
		PickedItemInfo.add_child(ItemPickUpInfo)
		Gameplay.addItem(item_name,item_identifier)
		if tree_item.uniqueness == true:
			Gameplay.storeStaticItems(picked_item.item_name,Gameplay.loaded_map)
	tree_item.free() #use free() instead of queue_free() here, this seems to fix an issue with interactionRayDetection() in Player



func getItemPositionInInventory(item_name: String,target_inventory: Array) -> int:
	var index = 0
	if target_inventory.size() > 0:
		while item_name != target_inventory[index]:
			index += 1
	return index


func updateHudItemText() -> void:
	Hud.getWeaponLabel().text = Designators.represent("item",Gameplay.equipped_weapon)
	Hud.getUsableLabel().text = Designators.represent("item",Gameplay.equipped_usable)
	if Gameplay.isPersistent(Gameplay.equipped_usable):
		Hud.getUsableAmountLabel().visible = false
	else:
		Hud.getUsableAmountLabel().visible = true
		Hud.getUsableAmountLabel().text = str(Gameplay.getUsableAmount(Gameplay.equipped_usable))


func chooseWeapon(specifier) -> void:
	if specifier == "at_runtime":
		for i in 3:
			if Input.is_action_just_pressed("item_"+str(i+1)): #item here stands for weapon, not ideal
				weapon_selector = i 
				weaponEquipper(weapon_selector)
		weapon_in_hand = Gameplay.equipped_weapons[weapon_selector]
		Gameplay.get_node("EquippedWeapon").text = weapon_in_hand
	if specifier == "at_game_resume":
		weapon_selector = Gameplay.weapon_selector
		weaponEquipper(weapon_selector)
		weapon_in_hand = Gameplay.equipped_weapons[weapon_selector]
		Gameplay.get_node("EquippedWeapon").text = weapon_in_hand
	if RightHand.get_child_count() != 0:
		WeaponParent = RightHand.get_child(0) #establishes the actual weapon as the weapon the player holds in their hands
	WeaponParent = RightHand.get_child(0)
	Gameplay.equipped_weapon = weapon_in_hand
	updateHudItemText()


func weaponEquipper(selector) -> void: #actually adds the weapon scene into the players right hand
	for i in 3:
		pass
	var RightHandWeapon = null
	if RightHand.get_child_count() != 0:
		RightHandWeapon = RightHand.get_child(0)
		RightHand.remove_child(RightHandWeapon)
		#RightHand.add_child(load("res://Scenes/Weapons/"+Gameplay.equipped_weapon+".tscn").instantiate()) #change for directory of actual weapons later (no more test weapons)
	
	RightHand.add_child(load("res://Scenes/Weapons/"+str(Gameplay.equipped_weapons[selector])+".tscn").instantiate())
	WeaponParent = RightHand.get_child(0)
	WeaponParent.get_node("Weapon").position.y = -0.2 #overwrites the weapon of the player
	Gameplay.equipped_weapon = str(weapon_in_hand)


func chooseUsable(specifier) -> void:
	if specifier == "at_spawn":
		usable_selector = Gameplay.usable_selector
		usable_in_hand = Gameplay.equipped_usable
		Gameplay.get_node("EquippedUsable").text = usable_in_hand
	if specifier == "at_runtime":
		var up = Input.is_action_just_pressed("usable_up")
		var down = Input.is_action_just_pressed("usable_down")
		if up or down:
			if up:
				match usable_selector:
					0:
						usable_selector = 1
					1:
						usable_selector = 2
					2:
						usable_selector = 0
			if down:
				match usable_selector:
					0:
						usable_selector = 2
					2:
						usable_selector = 1
					1:
						usable_selector = 0
		Gameplay.usable_selector = usable_selector
		Gameplay.equipped_usable = Gameplay.equipped_usables[usable_selector]
		Gameplay.get_node("EquippedUsable").text = Gameplay.equipped_usable


func itemSway(delta) -> void:
	var camera_rotation = Camera.rotation
	Camera.position = UpperBodyCollision.position + Vector3(0,0.3,0)
	var right_hand_goal_position = Camera.position + right_hand_offset.rotated(Vector3(0,0,1),-camera_rotation.x).rotated(Vector3.UP,camera_rotation.y - PI/2) - Vector3(0,0.005*velocity.length(),0)
	RightHand.position += weapon_inertia * delta * (right_hand_goal_position - RightHand.position)
	RightHand.rotation += weapon_inertia * delta * (Vector3(camera_rotation.x / vertical_cam_factor,camera_rotation.y,camera_rotation.z) - RightHand.rotation)
	ItemSounds.position = RightHand.position
	ItemSounds.rotation = RightHand.rotation


func getStamina() -> float:
	return stamina


func setStamina(value: float) -> void:
	stamina = value


func getHealth() -> float:
	return health


func getHud() -> Node:
	return Hud


func getPickUpInfoHandler() -> Node:
	return PickUpInfoHandler


func setHealth(value: float) -> void:
	if value <= 0:
		health = 0
	else:
		health = value


func interpolator(init,final,duration,arg) -> Vector3:
	return init + (final - init) * 16.0 / (duration**4) * (arg / 2)**2 * (duration - arg / 2)**2


func mouseAiming(delta,smoothing) -> Vector2:
	if frame_counter == 0:
		frame_counter = 1
	else:
		frame_counter = 0
	var pos_1 = get_viewport().get_mouse_position()
	var screen_size_factor = get_viewport().size.x / 1152 #1152 is the size I used when writing this function. 
	if get_viewport().has_focus():
		Input.warp_mouse(Vector2(get_viewport().size.x / 2,get_viewport().size.y / 2))
	var pos_2 = get_viewport().get_mouse_position()
	if frame_counter == 1:
		mouse_distance = (pos_1 - pos_2) * screen_size_factor
	latent_mouse_distance += -delta * smoothing * ( latent_mouse_distance - mouse_distance )
	if dead:
		return Vector2.ZERO
	else:
		return latent_mouse_distance


func floorTypeDetector(floor_) -> void:
	StepSound = get_node("FootstepSounds"+str(floor_.get_child(0).name)) #detect the collider (the floor type)


func doForces(delta) -> Vector3: #gravity and air resistance
	var jump = Vector3.ZERO
	if is_on_floor() and Input.is_action_pressed("jump") and Gameplay.enough_stamina:
		#crouch(delta,20,-1,0.5,true)
		StepSound.play()
		jump = jump_coefficient * Vector3(0,1,0) #default coefficient 250
		#Camera.position.y += 0.1 #head inertia when jumping (want this also when landing)
		Gameplay.drainStamina(self,75 * Gameplay.staminaDrainFactor(strength_factor,strength,weight_factor,weight))
	return delta * ( gravity - air_resistance / mass * velocity * velocity.length() + jump)


func legMovement() -> Vector3:
	var forward_backward = 0
	var left_right = 0
	if Input.is_action_pressed("move_forward"):
		forward_backward = 1
	if Input.is_action_pressed("move_backward"):
		forward_backward = -1
	if Input.is_action_pressed("move_right"):
		left_right = 1
	if Input.is_action_pressed("move_left"):
		left_right = -1
	return Vector3(forward_backward,0,left_right).normalized()


func cameraTilt(delta) -> void:
	var plane_look_direction = Vector2(cos(Camera.rotation.y - PI/2),sin(Camera.rotation.y - PI/2))
	var plane_velocity = Vector2(velocity.z,velocity.x)
	var tilt_strength = 0
	if plane_velocity != Vector2.ZERO:
		tilt_strength = 0.02 * plane_look_direction.dot(plane_velocity)
	Camera.rotation.z += -10 * delta * (Camera.rotation.z - tilt_strength)


func changeFOV(value) -> void:
	Camera.fov = value


func cameraBob(speed,delta) -> float:
	if is_on_floor() and speed > 0.1:
		bob_cycle += delta * speed
		if bob_cycle  >= PI:
			bob_cycle = 0
			has_stepped = false
		if bob_cycle >= PI/3 and not has_stepped:
			StepSound.play()
			has_stepped = true
	else:
		bob_cycle += -delta * bob_cycle
	#bob_height += 5 * delta * (-0.1 * sin(bob_cycle)**2 - bob_height)
	return -0.1 * sin(bob_cycle)**2


func getCameraRotation() -> Vector3:
	return Vector3(Camera.rotation.x,Camera.rotation.y,0)


func setCameraRotation(camera_rotation) -> void:
	Camera.rotation = camera_rotation


func killPlayer(delta) -> void:
	if health <= 0:
		dead = true
	if dead and rotation.z > -PI/2:
		rotation.z -= delta
	if rotation.z <= -PI/2:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Gameplay.get_node("GameOverScreenHandler").visible = true
		Gameplay.get_node("GameOverScreenHandler").add_child(load("res://Scenes/Gameplay_Scenes/GameOverScreen/game_over_screen.tscn").instantiate())
		Gameplay.get_node("VirtualSpace").process_mode = PROCESS_MODE_DISABLED


func positioning(delta) -> Vector3: #running and crouching
	if !dead:
		var crouch_fac = 1
		var run_fac = 1
		var goal_velocity = Vector3.ZERO
		var camera_corrected_velocity = Vector3.ZERO
		var camera_rotation_corrected = Camera.rotation.y - PI/2
		if Input.is_action_pressed("run") and Gameplay.enough_stamina:
			run_fac = run_multiplier 
			if Vector2(velocity.x,velocity.z).length() > 1.5: #cutoff on the draining effect, if one is slower than 1.5 (arbitrary choice)
				Gameplay.drainStamina(self,0.35)
		#calculate goal_velocity, which is the desired velocity attained by crouching, sprinting, or walking
		goal_velocity = Vector3(walk_speed * crouch_fac * run_fac * legMovement().x,0,walk_speed * crouch_fac * run_fac * legMovement().z)
		#rotate the goal_velocity with the camera 
		camera_corrected_velocity = -Vector3(goal_velocity.x * cos(camera_rotation_corrected) + goal_velocity.z * sin(camera_rotation_corrected),0,-goal_velocity.x * sin(camera_rotation_corrected) + goal_velocity.z * cos(camera_rotation_corrected))
		mass_inert_velocity += -(float(mass) / resistance_factor) * delta * (mass_inert_velocity - camera_corrected_velocity) 
		return mass_inert_velocity
	else:
		return Vector3.ZERO


func landerHandler(_delta) -> void: #landing sound, camera behavior upon landing and fall damage
	if not is_on_floor():
		airborne = true
		if velocity.y < 0:
			impact = -10 * velocity.y #arbitrary choice of 3 for the damage
	if is_on_floor() and airborne:
		if impact > landing_resilience:
			health -= 2 * (impact - landing_resilience) #resilience towards light falls
		StepSound.play()
		airborne = false
		impact = 0
		bob_cycle  = 0


func velocityUpdater(delta) -> void:
	if in_water:
		walk_speed = water_speed
	else:
		walk_speed = dry_speed
	if is_on_floor():
		velocity.x = positioning(delta).x
		velocity.z = positioning(delta).z 

	velocity.y += doForces(delta).y


func mouseMovement(delta) -> void:
	var camera_turn = mouseAiming(delta,25)
	Camera.rotation.y -= camera_sensitivity * camera_speed.x * camera_turn.x
	Camera.rotation.x = clampf(Camera.rotation.x - camera_sensitivity * camera_speed.y * camera_turn.y,-PI/2,PI/2)


func showLevelUp(xp_type: String) -> void:
	var level_up_label = load("res://Scenes/HUD/level_up_label.tscn").instantiate()
	match xp_type:
		"general":
			level_up_label.get_node("Label").text = "Level Up"
		"physical":
			level_up_label.get_node("Label").text = "Physical Up"
		"magic":
			level_up_label.get_node("Label").text = "Magic Up"
	Hud.add_child(level_up_label)


func _ready() -> void:
	Signals.show_level_up.connect(showLevelUp)
	chooseWeapon("at_game_resume")
	chooseUsable("at_spawn")
	camera_sensitivity = Gameplay.camera_sensitivity 


func _physics_process(delta: float) -> void:
	crouchPositioning(delta)
	itemSway(delta)
	landerHandler(delta)
	cameraTilt(delta)
	mouseMovement(delta)
	velocityUpdater(delta)
	cameraBob(velocity.length(),delta)
	if !voided:
		move_and_slide()
	Gameplay.increaseStamina(self,delta,recovery_inhibition)
	Gameplay.staminaDrainPause(delta)
	interactionRayDetection()
	if health <= 0:
		killPlayer(delta)


func _on_hit_box_area_entered(area: Area3D) -> void:
	var hitter_parent = area.get_parent()
	if "area_type" in hitter_parent:
		if hitter_parent.area_type == "hurt_box": #prevents hitboxes to be detected as sources of damage (only hurtboxes allowed). get_parent because the area is the weapon area3d and not the node controlling the variabless
			if !(HitBox in hitter_parent.store_collision): #prevents the hurtbox from hitting twice if it is left during a single attack
				Signals.take_damage.emit(area,self)
				CombatFunctions.playHitSound(hitter_parent,self)
				hitter_parent.store_collision.append(HitBox)


func _on_ground_detector_body_entered(body: Node3D) -> void:
	floorTypeDetector(body)


func _on_interaction_region_area_entered(area: Area3D) -> void:
	Gameplay.showInteractionPrompt(area.get_parent().type)


func attackStatePusher(chain_length: int) -> void:
	attack_state += 1
	if attack_state > chain_length:
		attack_state = 1


func shakeFOV(amount: float) -> void:
	Camera.fov -= amount


func attack() -> void:
	var weapon_name = WeaponParent.item_name
	WeaponParent.attack_type = attack_type
	var AttackAnimation = WeaponParent.getPivotAnimation()
	var Pivot = WeaponParent.get_node("Pivot")
	if !attacking:
		if make_weapon_ready:
			if weapon_name == "rifle":
				changeFOV(30)
				weapon_inertia = 50
			Pivot.position = WeaponParent.ready_param[attack_state - 1][0]
			Pivot.rotation = WeaponParent.ready_param[attack_state - 1][1]
			vertical_cam_factor = 1
			recovery_inhibition = 10
			if Input.is_action_just_pressed("left_click"):
				ChargeHeavy.start()
			if Input.is_action_just_released("left_click") and make_weapon_ready:
				attacking = true
				ChargeHeavy.stop()
				var weapon_sound = CombatFunctions.getSound(WeaponParent,attack_type)
				weapon_sound.pitch_scale = randf_range(0.9,1.1)
				weapon_sound.play()
				AttackBlocker.start(WeaponParent.get(attack_type+"_attack_blocker"))
				AttackAnimation.play(attack_type+"_"+str(attack_state))
				Gameplay.drainStamina(self,WeaponParent.get(attack_type+"_stamina_cost"))
				attackStatePusher(2)
		else:
			WeaponParent.resetPivot()
			changeFOV(80)
			weapon_inertia = 15


func _on_charge_heavy_timeout() -> void:
	attack_type = "heavy"


func _on_attack_blocker_timeout() -> void:
	var Pivot = WeaponParent.get_node("Pivot")
	vertical_cam_factor = 2
	recovery_inhibition = 1
	attack_over = true
	attack_type = "light"
	WeaponParent.getPivotAnimation().stop()
	Pivot.position = WeaponParent.ready_param[attack_state - 1][0]
	Pivot.rotation = WeaponParent.ready_param[attack_state - 1][1]
	attacking = false
	WeaponParent.store_collision = []


func _on_attack_timer_timeout() -> void:
	attack_over = true
	attack_state = 1
	attack_type = "light"
	WeaponParent.attack_type = attack_type
	WeaponParent.getPivotAnimation().stop()
	WeaponParent.resetPivot()


func _on_dialogue_pause_timeout() -> void:
	GameplayPromptHandler.visible = true


func _on_ceiling_detector_body_entered(_body: Node3D) -> void:
	crouching = true


func _on_ceiling_detector_body_exited(_body: Node3D) -> void:
	crouching = false


func _on_spawn_timer_timeout() -> void:
	$SpawnHurtBox/CollisionShape3D.set_deferred("disabled",true)
	
