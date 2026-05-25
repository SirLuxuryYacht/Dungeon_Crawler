extends Node


func unitStep(x: float) -> int:
	if x > 0:
		return 1
	else:
		return 0


func killAndUpdate(Who: Node3D) -> void:
	var Gameplay = get_tree().root.get_node("Main/Gameplay")
	var loaded_map = Gameplay.loaded_map
	Who.queue_free()
	EnemyReference.assignPermanencyStatus(Gameplay,loaded_map,Who.id)


func addKillExperience(Gameplay: Node,amount: float) -> void:
	Gameplay.player_xp += amount
	var level_before = Gameplay.player_level
	updateLevel(Gameplay,"general")
	var level_after = Gameplay.player_level
	if level_after > level_before:
		Signals.show_level_up.emit("general")


func addHitExperience(Gameplay: Node,WeaponHitBox: Area3D,WhoGotHurt: Node3D) -> void: #does the xp gained by punching obey the same logarithmic law as the general level?
	var Weapon = WeaponHitBox.get_parent()
	var damage = [0,0,0,0]
	match Weapon.attack_type:
		"light":
			damage = Weapon.light_damage
		"heavy":
			damage = Weapon.heavy_damage
	var physical_add = damage[0] * WhoGotHurt.resistance[0]
	Gameplay.player_physical_xp += unitStep(physical_add) #evaluates if the product is greater than 0 and adds it to the player's physical xp
	var magic_xp = 0
	for i in 3:
		var magic_add = damage[i+1] * WhoGotHurt.resistance[i+1]
		magic_xp += unitStep(magic_add)
	Gameplay.player_magic_xp += magic_xp
	var physical_level_before = Gameplay.player_physical_level
	var magic_level_before = Gameplay.player_magic_level
	updateLevel(Gameplay,"physical")
	updateLevel(Gameplay,"magic")
	var physical_level_after = Gameplay.player_physical_level
	var magic_level_after = Gameplay.player_magic_level
	if physical_level_after > physical_level_before:
		Signals.show_level_up.emit("physical")
	if magic_level_after > magic_level_before:
		Signals.show_level_up.emit("magic")
	addKillExperience(Gameplay,1) #maybe as some gimmick, each hit also increases the general xp


func levelCurve(xp: float,xp_type) -> int:
	var value = 0
	match xp_type:
		"general":
			value = floor(0.02892 * xp +1)**(0.36206)
		"physical":
			value = floor(11.0/2 * log(0.01 * (xp + 1) + 1) + 1)
		"magic":
			value = floor(11.0/2 * log(0.01 * (xp + 1) + 1) + 1)
	return value #returns the calculated level from xp


func resistanceCurve(lvl: float) -> float: #lvl is composed of general level and the physical/magical level to give two different values for the resistances physical/magical
	return snapped(5 * (1 + tanh((lvl - 25.7)/5.2)) + sqrt(lvl + 2) - 0.7327993,0.05) #extremely arbitrary function with a bump at around lvl 26 with a steep increase in resistance


func fireProjectile(Gameplay: Node, Projectile: CharacterBody3D, radius: float, damage: Array, velocity: Vector3,damping: float, lifetime: float,where: Vector3, rotation: Vector3) -> void:
	Projectile.initial_velocity = velocity
	Projectile.lifetime = lifetime
	Projectile.damage = damage
	Projectile.damping = damping
	Projectile.radius = radius
	Projectile.get_node("Weapon").rotation.x = rotation.x
	Projectile.get_node("InteractionArea").rotation.x = rotation.x
	Gameplay.addMisc(Projectile,where,rotation)


func updateLevel(Gameplay: Node,xp_meter: String) -> void:
	var player_resistance = Gameplay.getPlayer().resistance
	match xp_meter:
		"general":
			Gameplay.player_level = levelCurve(Gameplay.player_xp,"general")
		"physical":
			Gameplay.player_physical_level = levelCurve(Gameplay.player_physical_xp,"physical")
			player_resistance[0] = resistanceCurve((Gameplay.player_level + Gameplay.player_physical_level))
		"magic":
			Gameplay.player_magic_level = levelCurve(Gameplay.player_magic_xp,"magic")
			var magic_resistance = resistanceCurve((Gameplay.player_level + Gameplay.player_magic_level)/2)
			for i in 3:
				player_resistance[i+1] = magic_resistance
	Gameplay.player_resistance = player_resistance #writes all the resistance info onto the gameplay node for saving


func particleImpact(Gameplay: Node, strength: String, where: Vector3,particle_type: String,normal_vector: Vector3,shading: bool) -> void:
	var Particles = load("res://Scenes/Sprites/dust_particles.tscn").instantiate()
	match particle_type:
		"dust":
			Particles.texture = "res://Textures/Sprite/Dust/dust_particle.png"
		"muzzle":
			Particles.texture = "res://Textures/Sprite/Dust/muzzle_particles.png"
		"water":
			Particles.texture = "res://Textures/Sprite/Water_Splash/water_splash.png"
	match strength:
		"weak":
			Particles.particle_amount = 20
			Particles.effect_duration = 0.5
			Particles.area_radius = 0.2
			Particles.damping = 0.25
		"medium":
			Particles.particle_amount = 65
			Particles.effect_duration = 1
			Particles.area_radius = 0.35
			Particles.damping = 0.175
		"strong":
			Particles.particle_amount = 100
			Particles.effect_duration = 1.5
			Particles.area_radius = 0.5
			Particles.damping = 0.1
	Particles.shading = shading
	Particles.normal_vector = normal_vector
	Gameplay.addMisc(Particles,where,Vector3.ZERO)


func getSound(FromWho: Node3D,type: String) -> AudioStreamPlayer3D:
	if type == "light":
		return  FromWho.get_node("Weapon/Light")
	elif type == "heavy":
		return FromWho.get_node("Weapon/Heavy")
	elif type == "hit":
		return FromWho.get_node("Weapon/Hit")
	else:
		return null


func playHitSound(hitter,hit) -> void:
	var hit_body_type = hit.body_type
	var hitter_sound = getSound(hitter,"hit")
	var hitter_type = hitter.get("weapon_type")
	var hit_effect 
	if hitter_type != "environmental":
		hit_effect = load("res://Sounds/Impacts/"+hit_body_type+"_"+hitter_type+".ogg")
		if hitter_sound != null:
			hitter_sound.stream = hit_effect
	hitter_sound.pitch_scale = randf_range(0.9,1.1)
	hitter_sound.play()
