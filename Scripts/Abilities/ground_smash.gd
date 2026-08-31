extends Node3D

@export var damage: float = 34.0
@export var radius: float = 5.5
@export var duration: float = 0.45

var caster: CharacterBody3D
var target: CharacterBody3D

func setup(p_caster: CharacterBody3D, p_target: CharacterBody3D, p_damage: float) -> void:
	caster = p_caster
	target = p_target
	damage = p_damage

func _ready() -> void:
	var ring = get_node_or_null("ShockwaveRing")
	if ring:
		var tween = create_tween()
		tween.tween_property(ring, "scale", Vector3(6.5, 1.0, 6.5), duration)
		tween.tween_callback(queue_free)
	else:
		get_tree().create_timer(duration).timeout.connect(queue_free)
	
	# Apply radial damage
	if target and is_instance_valid(target) and target.current_state != target.CharacterState.DEAD:
		var dist = global_position.distance_to(target.global_position)
		if dist <= radius:
			var dir = (target.global_position - global_position).normalized()
			target.take_damage(damage, "earthquake", dir + Vector3(0, 0.6, 0), 7.0)
			if caster and caster.has_signal("character_hit"):
				caster.emit_signal("character_hit", damage, true, target.global_position + Vector3(0, 1.2, 0))
