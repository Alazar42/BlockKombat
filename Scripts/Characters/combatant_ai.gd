extends Node

# Reference to the CharacterBody3D it controls
@onready var character = get_parent()

enum FighterTactic {
	STALK,          # Deliberate forward movement / cutting off the ring
	CIRCLE,         # Lateral strafing (circling the opponent)
	STARE_DOWN,     # Patient fighting stance / sizing up
	BAIT_RETREAT,   # Step back slightly to bait a whiff
	LUNGE_ATTACK,   # Burst in to strike
	IN_POCKET       # Close-quarters brawl (punches, kicks, blocks)
}

var current_tactic: FighterTactic = FighterTactic.STARE_DOWN
var target: CharacterBody3D

# Tactical Timers
var tactic_duration: float = 1.0
var tactic_timer: float = 0.0
var next_attack_time: float = 0.0
var block_cooldown_time: float = 0.0

# Movement Parameters
var circle_direction: float = 1.0 # 1.0 = clockwise, -1.0 = counter-clockwise
var sprint_burst: bool = false

# Fighter Personality & Awareness
var aggression: float = 0.65 # 0.0 (tactical/patient) to 1.0 (hyper-aggressive)
var block_reaction_chance: float = 0.45
var last_target_attack_state: int = 0

func _ready() -> void:
	if character:
		character.is_ai = true
		character.character_name = "Combatant AI"
		
		# Modulate aggression based on character stats
		if character.attack_multiplier > 1.0:
			aggression += 0.15
		if character.defense_multiplier > 1.0:
			block_reaction_chance += 0.2
	
	circle_direction = 1.0 if randf() > 0.5 else -1.0
	_pick_new_tactic(4.0)

func _physics_process(delta: float) -> void:
	if not character or not is_instance_valid(character):
		return
	
	if character.current_state in [character.CharacterState.DEAD, character.CharacterState.VICTORY]:
		return
	
	# Find opponent if not set
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

	# Handle attacking or hurt animation lock
	if character.current_state in [character.CharacterState.PUNCHING, character.CharacterState.KICKING, character.CharacterState.HURT]:
		character.velocity.x = move_toward(character.velocity.x, 0, 15.0 * delta)
		character.velocity.z = move_toward(character.velocity.z, 0, 15.0 * delta)
		return

	var dist = character.global_position.distance_to(target.global_position)
	var dir_to_target = (target.global_position - character.global_position).normalized()
	dir_to_target.y = 0

	# 1. Always keep eyes and body squarely locked onto the opponent
	if dir_to_target.length() > 0.1:
		var target_rot = character.get_facing_rotation(dir_to_target)
		character.rotation.y = lerp_angle(character.rotation.y, target_rot, 12.0 * delta)

	# 2. Check reactive block against incoming player strikes
	_check_reactive_guard(dist)

	# 3. Check whiff punish opportunity (if player swings and misses near AI)
	_check_whiff_punish(dist)

	# 4. Update tactical behavior state machine
	tactic_timer += delta
	if tactic_timer >= tactic_duration:
		_pick_new_tactic(dist)

	# 5. Execute current tactical movement & combat
	_execute_tactic(dist, dir_to_target, delta)

func _find_target() -> void:
	var fighters = get_tree().get_nodes_in_group("fighters")
	for f in fighters:
		if f != character and is_instance_valid(f):
			target = f
			character.set_target(target)
			break

func _check_reactive_guard(dist: float) -> void:
	if not target or not is_instance_valid(target) or character.is_blocking:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time < block_cooldown_time:
		return

	if dist <= 2.8 and target.current_state in [target.CharacterState.PUNCHING, target.CharacterState.KICKING]:
		if randf() < block_reaction_chance:
			character.start_blocking()
			block_cooldown_time = current_time + randf_range(1.2, 2.0)
			
			# Hold block briefly to deflect the strike
			var tw = create_tween()
			tw.tween_interval(randf_range(0.3, 0.55))
			tw.tween_callback(func():
				if is_instance_valid(character) and character.is_blocking:
					character.stop_blocking()
			)

func _check_whiff_punish(dist: float) -> void:
	if not target or not is_instance_valid(target):
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time < next_attack_time:
		return

	# If player just finished a missed swing at medium range, lunge in and punish!
	if dist > 2.2 and dist < 3.8 and target.current_state in [target.CharacterState.PUNCHING, target.CharacterState.KICKING]:
		if randf() < 0.6:
			current_tactic = FighterTactic.LUNGE_ATTACK
			tactic_duration = 0.8
			tactic_timer = 0.0
			sprint_burst = true

func _pick_new_tactic(dist: float) -> void:
	tactic_timer = 0.0
	var roll = randf()

	# Alternate circling direction occasionally
	if randf() < 0.4:
		circle_direction *= -1.0

	sprint_burst = (randf() < 0.3)

	if dist > 5.5:
		# Long range - Stalk, Circle or Observe
		if roll < 0.45:
			current_tactic = FighterTactic.STALK
			tactic_duration = randf_range(1.2, 2.2)
		elif roll < 0.80:
			current_tactic = FighterTactic.CIRCLE
			tactic_duration = randf_range(1.0, 2.0)
		else:
			current_tactic = FighterTactic.STARE_DOWN
			tactic_duration = randf_range(0.8, 1.6)

	elif dist >= 2.4 and dist <= 5.5:
		# Mid range (The Pocket Boundary) - Footwork, Baiting, Lunges
		if roll < 0.35:
			current_tactic = FighterTactic.CIRCLE
			tactic_duration = randf_range(1.0, 2.2)
		elif roll < 0.65:
			current_tactic = FighterTactic.LUNGE_ATTACK
			tactic_duration = randf_range(0.8, 1.4)
		elif roll < 0.85:
			current_tactic = FighterTactic.BAIT_RETREAT
			tactic_duration = randf_range(0.6, 1.2)
		else:
			current_tactic = FighterTactic.STALK
			tactic_duration = randf_range(0.8, 1.5)

	else:
		# Close range (< 2.4m) - In the pocket brawl
		current_tactic = FighterTactic.IN_POCKET
		tactic_duration = randf_range(0.6, 1.2)

func _execute_tactic(dist: float, dir_to_target: Vector3, delta: float) -> void:
	if character.is_blocking:
		character.velocity.x = move_toward(character.velocity.x, 0, 12.0 * delta)
		character.velocity.z = move_toward(character.velocity.z, 0, 12.0 * delta)
		return

	var current_time = Time.get_ticks_msec() / 1000.0
	var base_speed = character.BASE_SPEED * character.speed_multiplier

	match current_tactic:
		FighterTactic.STALK:
			# Advance forward deliberately
			var speed = base_speed * (1.3 if sprint_burst else 0.75)
			character.velocity.x = dir_to_target.x * speed
			character.velocity.z = dir_to_target.z * speed
			
			character.set_state(character.CharacterState.MOVING)
			character.play_animation("sprint" if sprint_burst else "walk", 0.12)
			
			if dist <= 2.3:
				_pick_new_tactic(dist)

		FighterTactic.CIRCLE:
			# Lateral strafe around the opponent
			var right_vec = Vector3(-dir_to_target.z, 0, dir_to_target.x) * circle_direction
			var circle_speed = base_speed * 0.65
			
			# Slight radial correction to maintain a 3.0m - 4.5m distance
			var radial_nudge = Vector3.ZERO
			if dist > 4.5:
				radial_nudge = dir_to_target * 0.4
			elif dist < 2.5:
				radial_nudge = -dir_to_target * 0.4
			
			var move_dir = (right_vec + radial_nudge).normalized()
			character.velocity.x = move_dir.x * circle_speed
			character.velocity.z = move_dir.z * circle_speed
			
			character.set_state(character.CharacterState.MOVING)
			character.play_animation("walk", 0.12)

		FighterTactic.STARE_DOWN:
			# Stand ground, maintain guard stance
			character.velocity.x = move_toward(character.velocity.x, 0, 12.0 * delta)
			character.velocity.z = move_toward(character.velocity.z, 0, 12.0 * delta)
			character.set_state(character.CharacterState.IDLE)
			character.play_animation("idle", 0.15)

		FighterTactic.BAIT_RETREAT:
			# Step back to bait a whiff
			var retreat_speed = base_speed * 0.7
			character.velocity.x = -dir_to_target.x * retreat_speed
			character.velocity.z = -dir_to_target.z * retreat_speed
			
			character.set_state(character.CharacterState.MOVING)
			character.play_animation("walk", 0.12)

		FighterTactic.LUNGE_ATTACK:
			# Rapid gap-closing attack
			var lunge_speed = base_speed * 1.35
			character.velocity.x = dir_to_target.x * lunge_speed
			character.velocity.z = dir_to_target.z * lunge_speed
			
			character.set_state(character.CharacterState.MOVING)
			character.play_animation("sprint", 0.08)
			
			if dist <= 2.4 and current_time >= next_attack_time:
				_perform_strike_combo(current_time)
				_pick_new_tactic(dist)

		FighterTactic.IN_POCKET:
			# Close range exchanges
			if dist > 2.4:
				# Step in slightly
				character.velocity.x = dir_to_target.x * (base_speed * 0.8)
				character.velocity.z = dir_to_target.z * (base_speed * 0.8)
			else:
				# Hold ground in striking range
				character.velocity.x = move_toward(character.velocity.x, 0, 12.0 * delta)
				character.velocity.z = move_toward(character.velocity.z, 0, 12.0 * delta)

			if current_time >= next_attack_time:
				_perform_strike_combo(current_time)

func _perform_strike_combo(current_time: float) -> void:
	if not character.can_attack():
		return

	var roll = randf()
	if roll < 0.65:
		# Punch combo
		character.execute_punch()
		next_attack_time = current_time + randf_range(0.32, 0.65)
	elif roll < 0.90:
		# Powerful kick
		character.execute_kick()
		next_attack_time = current_time + randf_range(0.42, 0.8)
	else:
		# Quick step back / reposition after attack
		current_tactic = FighterTactic.BAIT_RETREAT
		tactic_duration = 0.5
		tactic_timer = 0.0
		next_attack_time = current_time + 0.35
