extends Node3D

@export var damage: float = 36.0
@export var duration: float = 0.4

var caster: CharacterBody3D
var target: CharacterBody3D
var direction: Vector3 = Vector3.FORWARD

func setup(p_caster: CharacterBody3D, p_target: CharacterBody3D, p_dir: Vector3, p_damage: float) -> void:
	caster = p_caster
	target = p_target
	direction = p_dir.normalized()
	damage = p_damage
	
	if target and is_instance_valid(target) and target.current_state != target.CharacterState.DEAD:
		var dist = global_position.distance_to(target.global_position)
		if dist <= 9.0:
			target.take_damage(damage, "laser", direction, 5.5)
			if caster and caster.has_signal("character_hit"):
				caster.emit_signal("character_hit", damage, true, target.global_position + Vector3(0, 1.2, 0))

func _ready() -> void:
	get_tree().create_timer(duration).timeout.connect(queue_free)
