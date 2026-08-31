extends Node3D

@export var speed: float = 17.0
@export var damage: float = 24.0
@export var freeze_duration: float = 1.8
@export var max_lifetime: float = 2.0

var direction: Vector3 = Vector3.FORWARD
var caster: CharacterBody3D
var target: CharacterBody3D
var lifetime: float = 0.0

func setup(p_caster: CharacterBody3D, p_target: CharacterBody3D, p_dir: Vector3, p_damage: float) -> void:
	caster = p_caster
	target = p_target
	direction = p_dir.normalized()
	damage = p_damage

func _physics_process(delta: float) -> void:
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()
		return
	
	global_position += direction * (speed * delta)
	
	if target and is_instance_valid(target) and target.current_state != target.CharacterState.DEAD:
		var dist = global_position.distance_to(target.global_position + Vector3(0, 1.0, 0))
		if dist <= 1.2:
			target.take_damage(damage, "freeze", direction, 2.0)
			if target.has_method("freeze_in_place"):
				target.freeze_in_place(freeze_duration)
			if caster and caster.has_signal("character_hit"):
				caster.emit_signal("character_hit", damage, true, target.global_position + Vector3(0, 1.2, 0))
			queue_free()
