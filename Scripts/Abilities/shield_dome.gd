extends Node3D

@export var shield_points: float = 100.0
@export var duration: float = 3.5

var caster: CharacterBody3D

func setup(p_caster: CharacterBody3D, p_shield: float) -> void:
	caster = p_caster
	shield_points = p_shield
	if caster:
		caster.shield_hp = shield_points

func _ready() -> void:
	get_tree().create_timer(duration).timeout.connect(func():
		if caster:
			caster.shield_hp = 0.0
		queue_free()
	)
