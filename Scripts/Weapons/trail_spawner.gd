extends Node3D

@onready var initial_position

@onready var TrailParent

var has_started = false

var is_trailing = true

var lifetime: float

var duration: float

var intensity: int

var vertex_count_max: int = 10

var initial_velocity: Vector3

var trail_velocities: Array = []

var trail_velocity: Vector3

var vertex_count: int = 0

var trail_parameter: float = 0

var trail_vertex_positions: Array = []

@onready var GPUParticles = $GPUParticles3D

@onready var emission_material = $GPUParticles3D.process_material


func perpVec(input_vector:Vector3) -> Vector3:
	var vec_perp: Vector3
	if input_vector.x != 0:
		vec_perp.x = - initial_velocity.z / initial_velocity.x
		vec_perp = Vector3(vec_perp.x,0,1).normalized()
	else:
		vec_perp = Vector3(1,0,0)
	return vec_perp


func coneVelocity(_initial_velocity: Vector3) -> Vector3:
	var vec_perp = perpVec(initial_velocity)
	return _initial_velocity.length() / 20 * _initial_velocity.normalized().rotated(vec_perp.normalized(),randf_range(-PI/8,PI/8)).rotated(_initial_velocity.normalized(),randf_range(0,2*PI))


func _ready() -> void:
	$Timer.start(duration)
	GPUParticles.lifetime = float(lifetime)
	GPUParticles.amount = intensity
	$SpawnTimer.start(duration / vertex_count_max)
	_on_spawn_timer_timeout()


func _physics_process(delta: float) -> void:
	if !(TrailParent == null):
		if vertex_count < 2:
			trail_velocities.append(coneVelocity(TrailParent.velocity))
			vertex_count += 1
		else:
			if !has_started:
				GPUParticles.emitting = true
				has_started = true
			trail_parameter += delta * (vertex_count_max / duration)
			trail_velocity = trail_velocities[vertex_count - 2] + trail_parameter * (trail_velocities[vertex_count - 1] - trail_velocities[vertex_count - 2])
			var trail_velocity_length = trail_velocity.length()
			GPUParticles.process_material.direction = trail_velocity
			GPUParticles.process_material.set_param_max(0,trail_velocity_length)
			GPUParticles.process_material.set_param_min(0,trail_velocity_length)
		GPUParticles.position = TrailParent.position - position
	else:
		GPUParticles.emitting = false


func _on_timer_timeout() -> void:
	if !is_trailing:
		self.queue_free()
	else:
		$Timer.start(lifetime)
		is_trailing = false
		GPUParticles.emitting = false


func _on_spawn_timer_timeout() -> void:
	if is_trailing:
		if !(TrailParent == null):
			trail_velocities.append(coneVelocity(TrailParent.velocity))
			trail_vertex_positions.append(TrailParent.position - position)
			vertex_count += 1
			trail_parameter = 0
