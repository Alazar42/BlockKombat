extends Node

# Reference to the CharacterBody3D it controls
@onready var character = get_parent()

enum AIState {
	IDLE,
	APPROACH,
	COMBAT,
	STRAFE,
	RETREAT,
	BLOCKING
}

var current_ai_state: AIState = AIState.IDLE
var target: CharacterBody3D
var state_timer: float = 0.0
var next_action_time: float = 0.0
var strafe_direction: float = 1.0
var reaction_check_timer: float = 0.0

# Difficulty / Behavior tuning
var aggression: float = 0.75 # 0.0 (passive) to 1.0 (very aggressive)
var reaction_time: float = 0.35
var block_chance: float = 0.35

func _ready() -> void:
	if character:
		character.is_ai = true
		character.character_name = "Combatant AI"

func _physics_process(delta: float) -> void:
	if not character or not is_instance_valid(character):
		return
	
	if character.current_state in [character.CharacterState.DEAD, character.CharacterState.VICTORY]:
		return
	
	# Find target if not set
	if not target or not is_instance_valid(target):
		_find_target()
		return
	
	if target.current_state == target.CharacterState.DEAD:
		character.velocity.x = move_toward(character.velocity.x, 0, 10.0 * delta)
		character.velocity.z = move_toward(character.velocity.z, 0, 10.0 * delta)
		if character.current_state not in [character.CharacterState.VICTORY, character.CharacterState.DEAD]:
			character.set_state(character.CharacterState.IDLE)
			character.play_animation("idle", 0.15)
		return

	state_timer += delta
	reaction_check_timer += delta

	# Check reactive blocking
	if reaction_check_timer >= reaction_time:
		reaction_check_timer = 0.0
		_check_reactive_defense()

	var dist = character.global_position.distance_to(target.global_position)
	var dir_to_target = (target.global_position - character.global_position).normalized()
	dir_to_target.y = 0

	# Always smoothly face the opponent
	if dir_to_target.length() > 0.1:
		var target_rot = character.get_facing_rotation(dir_to_target)
		character.rotation.y = lerp_angle(character.rotation.y, target_rot, 10.0 * delta)

	# Decide AI State
	_update_ai_state(dist, delta)

func _find_target() -> void:
	var fighters = get_tree().get_nodes_in_group("fighters")
	for f in fighters:
		if f != character and is_instance_valid(f):
			target = f
			character.set_target(target)
			break

func _check_reactive_defense() -> void:
	if not target or not is_instance_valid(target):
		return
	
	var dist = character.global_position.distance_to(target.global_position)
	if dist < 2.5:
		if target.current_state in [target.CharacterState.PUNCHING, target.CharacterState.KICKING]:
			if randf() < block_chance and not character.is_blocking:
				character.start_blocking()
				await get_tree().create_timer(0.4).timeout
				if is_instance_valid(character) and character.is_blocking:
					character.stop_blocking()

func _update_ai_state(dist: float, delta: float) -> void:
	if character.current_state in [character.CharacterState.PUNCHING, character.CharacterState.KICKING, character.CharacterState.HURT]:
		character.velocity.x = move_toward(character.velocity.x, 0, 15.0 * delta)
		character.velocity.z = move_toward(character.velocity.z, 0, 15.0 * delta)
		return

	if character.is_blocking:
		character.velocity.x = move_toward(character.velocity.x, 0, 10.0 * delta)
		character.velocity.z = move_toward(character.velocity.z, 0, 10.0 * delta)
		return

	var current_time = Time.get_ticks_msec() / 1000.0

	if dist > 2.3:
		# Approach target
		var dir = (target.global_position - character.global_position).normalized()
		dir.y = 0
		var move_speed = character.BASE_SPEED * character.speed_multiplier * 0.95
		character.velocity.x = dir.x * move_speed
		character.velocity.z = dir.z * move_speed
		
		character.set_state(character.CharacterState.MOVING)
		character.play_animation("walk", 0.12)
	
	elif dist <= 2.3 and dist >= 1.0:
		# In striking range - Attack, Strafe, or Combos
		if current_time >= next_action_time:
			var roll = randf()
			if roll < 0.6:
				# Execute punch combo
				character.execute_punch()
				next_action_time = current_time + randf_range(0.35, 0.7)
			elif roll < 0.88:
				# Execute kick
				character.execute_kick()
				next_action_time = current_time + randf_range(0.45, 0.85)
			else:
				# Quick strafe / reposition
				strafe_direction = 1.0 if randf() > 0.5 else -1.0
				next_action_time = current_time + randf_range(0.4, 0.8)
		else:
			# Strafe around player while waiting
			var forward = (target.global_position - character.global_position).normalized()
			var right = Vector3(-forward.z, 0, forward.x) * strafe_direction
			var strafe_speed = character.BASE_SPEED * 0.55
			character.velocity.x = right.x * strafe_speed
			character.velocity.z = right.z * strafe_speed
			
			if character.velocity.length() > 0.2:
				character.set_state(character.CharacterState.MOVING)
				character.play_animation("walk", 0.12)
			else:
				character.set_state(character.CharacterState.IDLE)
				character.play_animation("idle", 0.12)
	else:
		# Too close - step back slightly to optimal range
		var retreat_dir = -(target.global_position - character.global_position).normalized()
		retreat_dir.y = 0
		var move_speed = character.BASE_SPEED * 0.6
		character.velocity.x = retreat_dir.x * move_speed
		character.velocity.z = retreat_dir.z * move_speed
		character.set_state(character.CharacterState.MOVING)
		character.play_animation("walk", 0.12)
