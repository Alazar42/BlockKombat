extends Node3D

@export var heal_amount: float = 70.0
@export var duration: float = 0.8

var caster: CharacterBody3D

func setup(p_caster: CharacterBody3D, p_heal: float) -> void:
	caster = p_caster
	heal_amount = p_heal
	
	if caster:
		caster.health = min(caster.health + heal_amount, caster.max_health)
		caster.emit_signal("health_changed", caster.health, caster.max_health)

func _ready() -> void:
	var mesh = get_node_or_null("AuraMesh")
	if mesh:
		var tween = create_tween()
		tween.tween_property(mesh, "position:y", 2.0, duration)
		tween.parallel().tween_property(mesh, "scale", Vector3(1.4, 1.0, 1.4), duration)
		tween.tween_callback(queue_free)
	else:
		get_tree().create_timer(duration).timeout.connect(queue_free)
