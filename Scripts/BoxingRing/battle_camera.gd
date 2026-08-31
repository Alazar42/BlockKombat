extends Camera3D

@export var fighter1: CharacterBody3D
@export var fighter2: CharacterBody3D

@export var min_distance: float = 6.0
@export var max_distance: float = 12.0
@export var base_height: float = 2.8
@export var smooth_speed: float = 5.0

var trauma: float = 0.0
var max_shake_offset: float = 0.35

func _ready() -> void:
	# Find fighters if not assigned
	if not fighter1 or not fighter2:
		_find_fighters()

func _find_fighters() -> void:
	var fighters = get_tree().get_nodes_in_group("fighters")
	if fighters.size() >= 2:
		fighter1 = fighters[0]
		fighter2 = fighters[1]

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

func _physics_process(delta: float) -> void:
	if not fighter1 or not fighter2:
		_find_fighters()
		if not fighter1 or not fighter2:
			return

	var p1_pos = fighter1.global_position
	var p2_pos = fighter2.global_position
	var midpoint = (p1_pos + p2_pos) * 0.5
	midpoint.y += 1.2 # Look at chest level

	var dist = p1_pos.distance_to(p2_pos)
	var cam_dist = clamp(dist * 1.1 + 4.5, min_distance, max_distance)
	var cam_height = clamp(cam_dist * 0.4 + 1.2, base_height, 6.0)

	# Position camera along side angle (e.g. looking from side of the ring)
	var target_pos = Vector3(midpoint.x, midpoint.y + cam_height, midpoint.z + cam_dist)
	
	# Smoothly interpolate position
	global_position = global_position.lerp(target_pos, smooth_speed * delta)
	
	# Apply screen shake trauma if active
	if trauma > 0:
		trauma = move_toward(trauma, 0, delta * 2.5)
		var shake = trauma * trauma
		global_position.x += (randf_range(-1.0, 1.0)) * max_shake_offset * shake
		global_position.y += (randf_range(-1.0, 1.0)) * max_shake_offset * shake

	# Look at midpoint
	look_at(midpoint, Vector3.UP)
