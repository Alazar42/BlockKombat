extends Node3D

@export var damage: float = 38.0
@export var duration: float = 0.35

var caster: CharacterBody3D
var target: CharacterBody3D

func setup(p_caster: CharacterBody3D, p_target: CharacterBody3D, p_damage: float) -> void:
	caster = p_caster
	target = p_target
	damage = p_damage
	
	if target and is_instance_valid(target):
		global_position = target.global_position
		target.take_damage(damage, "lightning", Vector3.UP * 0.5, 5.0)
		if caster and caster.has_signal("character_hit"):
			caster.emit_signal("character_hit", damage, true, target.global_position + Vector3(0, 1.2, 0))

func _ready() -> void:
	get_tree().create_timer(duration).timeout.connect(queue_free)
