extends CharacterBody3D

# Character Type Selection
@export var is_ai: bool = false
@export_enum(
	"character_a",
	"character_b",
	"character_c",
	"character_d",
	"character_e",
	"character_f",
	"character_g",
	"character_h",
	"character_i",
	"character_j",
	"character_k",
	"character_l",
	"character_m",
	"character_n",
	"character_o",
	"character_p",
	"character_q",
	"character_r"
) var character_type: String = "character_a"
@export var character_name: String = "Fighter"
@export var special_type: String = "fireball"
@export var special_name: String = "Fireball"

const CHARACTER_TEXTURES := {
	"character_a": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-a.png",
	"character_b": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-b.png",
	"character_c": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-c.png",
	"character_d": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-d.png",
	"character_e": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-e.png",
	"character_f": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-f.png",
	"character_g": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-g.png",
	"character_h": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-h.png",
	"character_i": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-i.png",
	"character_j": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-j.png",
	"character_k": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-k.png",
	"character_l": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-l.png",
	"character_m": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-m.png",
	"character_n": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-n.png",
	"character_o": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-o.png",
	"character_p": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-p.png",
	"character_q": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-q.png",
	"character_r": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-r.png"
}

# Preloaded Ability Prefabs
const PREFAB_FIREBALL = preload("res://Scenes/Abilities/fireball.tscn")
const PREFAB_ICE_FREEZE = preload("res://Scenes/Abilities/ice_freeze.tscn")
const PREFAB_HEAL_AURA = preload("res://Scenes/Abilities/heal_aura.tscn")
const PREFAB_GUNFIRE = preload("res://Scenes/Abilities/gunfire_blast.tscn")
const PREFAB_LIGHTNING = preload("res://Scenes/Abilities/lightning_strike.tscn")
const PREFAB_GROUND_SMASH = preload("res://Scenes/Abilities/ground_smash.tscn")
const PREFAB_LASER_BEAM = preload("res://Scenes/Abilities/laser_beam.tscn")
const PREFAB_SHIELD_DOME = preload("res://Scenes/Abilities/shield_dome.tscn")

# Material Cache for smooth loading
static var _material_cache: Dictionary = {}

# Movement Constants
const BASE_SPEED = 5.0
const JUMP_VELOCITY = 5.0
const ROTATION_SPEED = 12.0
const RING_LIMIT = 7.2

# Combat Constants
const BASE_PUNCH_DAMAGE = 8.0
const BASE_KICK_DAMAGE = 14.0
const PUNCH_RANGE = 2.6
const KICK_RANGE = 3.0
const BLOCK_DAMAGE_RATIO = 0.2
const ANIMATION_BLEND_TIME = 0.12

# Special Ability 10-Hit Meter
const MAX_SPECIAL_METER: float = 10.0
var special_meter: float = 0.0

# State Variables
enum CharacterState {
	IDLE,
	MOVING,
	PUNCHING,
	KICKING,
	SPECIAL,
	BLOCKING,
	HURT,
	DEAD,
	VICTORY
}

var current_state: CharacterState = CharacterState.IDLE
var health: float = 250.0
var max_health: float = 250.0
var is_blocking: bool = false
var is_frozen: bool = false
var shield_hp: float = 0.0

var combo_count: int = 0
var last_attack_time: float = 0.0
var combo_reset_time: float = 1.0
var attack_cooldown: float = 0.28

var speed_multiplier: float = 1.0
var attack_multiplier: float = 1.0
var defense_multiplier: float = 1.0

# References
var animation_player: AnimationPlayer
var target_node: CharacterBody3D

# Signals
signal health_changed(current_hp: float, max_hp: float)
signal special_meter_changed(current_meter: float, max_meter: float)
signal state_changed(new_state: CharacterState)
signal combo_updated(combo_count: int)
signal character_died(character: CharacterBody3D)
signal character_hit(damage: float, is_critical: bool, hit_pos: Vector3)

func _ready() -> void:
	find_and_cache_animation_player()
	load_character()
	emit_signal("health_changed", health, max_health)
	emit_signal("special_meter_changed", special_meter, MAX_SPECIAL_METER)

func get_forward_vector() -> Vector3:
	return global_transform.basis.x.normalized()

func get_facing_rotation(dir: Vector3) -> float:
	return atan2(dir.x, dir.z) - deg_to_rad(90)

func find_and_cache_animation_player() -> void:
	if not animation_player:
		animation_player = find_animation_player(self)
		if animation_player:
			for anim_name in ["idle", "walk", "sprint"]:
				if animation_player.has_animation(anim_name):
					var anim = animation_player.get_animation(anim_name)
					if anim:
						anim.loop_mode = Animation.LOOP_LINEAR

func find_animation_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found = find_animation_player(child)
		if found:
			return found
	return null

func load_character() -> void:
	var tex_path = CHARACTER_TEXTURES.get(character_type, CHARACTER_TEXTURES["character_a"])
	set_character_texture(tex_path)

func set_character_texture(texture_path: String) -> void:
	var mat: Material
	if _material_cache.has(texture_path):
		mat = _material_cache[texture_path]
	else:
		var tex = load(texture_path)
		if not tex:
			return
		var std_mat = StandardMaterial3D.new()
		std_mat.albedo_texture = tex
		std_mat.vertex_color_use_as_albedo = true
		std_mat.emission_enabled = false
		std_mat.roughness = 0.5
		std_mat.cull_mode = BaseMaterial3D.CULL_BACK
		_material_cache[texture_path] = std_mat
		mat = std_mat
	
	_apply_material_recursive(self, mat)

func _apply_material_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_override = mat
	for child in node.get_children():
		_apply_material_recursive(child, mat)

func apply_character_data(char_data: Dictionary) -> void:
	if char_data.is_empty():
		return
	character_name = char_data.get("name", "Fighter")
	character_type = char_data.get("key", "character_a")
	special_type = char_data.get("special_type", "fireball")
	special_name = char_data.get("special_name", "Special Attack")
	
	if char_data.has("texture"):
		set_character_texture(char_data.texture)
	else:
		load_character()
	
	var atk = float(char_data.get("attack", "80"))
	var def = float(char_data.get("defense", "80"))
	var spd = float(char_data.get("speed", "75"))
	
	attack_multiplier = max(0.6, atk / 80.0)
	defense_multiplier = max(0.6, def / 80.0)
	speed_multiplier = max(0.7, spd / 75.0)
	
	health = 250.0
	max_health = 250.0
	special_meter = 0.0
	emit_signal("health_changed", health, max_health)
	emit_signal("special_meter_changed", special_meter, MAX_SPECIAL_METER)

func add_special_meter(amount: float) -> void:
	special_meter = clamp(special_meter + amount, 0.0, MAX_SPECIAL_METER)
	emit_signal("special_meter_changed", special_meter, MAX_SPECIAL_METER)

func _physics_process(delta: float) -> void:
	var p = get_parent()
	if p and (p.name == "CharacterShowcase" or p.name == "CharacterStand"):
		return

	if current_state == CharacterState.DEAD or current_state == CharacterState.VICTORY:
		if not is_on_floor():
			velocity += get_gravity() * delta
			move_and_slide()
		return

	if is_frozen:
		velocity.x = move_toward(velocity.x, 0, 15.0 * delta)
		velocity.z = move_toward(velocity.z, 0, 15.0 * delta)
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	# Handle gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Check combo reset window
	var current_time = Time.get_ticks_msec() / 1000.0
	if combo_count > 0 and current_time - last_attack_time > combo_reset_time:
		combo_count = 0
		emit_signal("combo_updated", 0)

	# Handle movement & combat if controlled by player
	if not is_ai:
		handle_player_movement(delta)
		handle_player_combat(delta)
	
	# Clamp position inside ring
	global_position.x = clamp(global_position.x, -RING_LIMIT, RING_LIMIT)
	global_position.z = clamp(global_position.z, -RING_LIMIT, RING_LIMIT)
	
	move_and_slide()

func handle_player_movement(delta: float) -> void:
	if current_state in [CharacterState.PUNCHING, CharacterState.KICKING, CharacterState.SPECIAL, CharacterState.HURT, CharacterState.DEAD]:
		velocity.x = move_toward(velocity.x, 0, 15.0 * delta)
		velocity.z = move_toward(velocity.z, 0, 15.0 * delta)
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_vec := Vector3(input_dir.x, 0, input_dir.y)

	var move_speed = BASE_SPEED * speed_multiplier
	var is_running = Input.is_action_pressed("run")
	if is_running:
		move_speed *= 1.4

	if move_vec.length() > 0.05:
		move_vec = move_vec.normalized()
		velocity.x = move_vec.x * move_speed
		velocity.z = move_vec.z * move_speed

		var target_rot = get_facing_rotation(move_vec)
		if target_node and is_instance_valid(target_node) and global_position.distance_to(target_node.global_position) < 4.0:
			var opp_dir = (target_node.global_position - global_position).normalized()
			opp_dir.y = 0
			if opp_dir.length() > 0.1:
				target_rot = get_facing_rotation(opp_dir)
		
		rotation.y = lerp_angle(rotation.y, target_rot, ROTATION_SPEED * delta)

		if current_state != CharacterState.BLOCKING:
			set_state(CharacterState.MOVING)
			var anim = "sprint" if is_running else "walk"
			play_animation(anim, ANIMATION_BLEND_TIME)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0, move_speed * 8.0 * delta)

		if target_node and is_instance_valid(target_node) and target_node.current_state != CharacterState.DEAD:
			var opp_dir = (target_node.global_position - global_position).normalized()
			opp_dir.y = 0
			if opp_dir.length() > 0.1:
				var target_rot = get_facing_rotation(opp_dir)
				rotation.y = lerp_angle(rotation.y, target_rot, ROTATION_SPEED * delta)

		if current_state not in [CharacterState.BLOCKING, CharacterState.PUNCHING, CharacterState.KICKING, CharacterState.SPECIAL, CharacterState.HURT]:
			set_state(CharacterState.IDLE)
			play_animation("idle", ANIMATION_BLEND_TIME)

func handle_player_combat(_delta: float) -> void:
	# Block
	if Input.is_action_pressed("block") and current_state not in [CharacterState.PUNCHING, CharacterState.KICKING, CharacterState.SPECIAL, CharacterState.HURT]:
		start_blocking()
	elif Input.is_action_just_released("block") and is_blocking:
		stop_blocking()

	if is_blocking:
		return

	# Special Attack (Requires 10 hits full meter)
	if Input.is_action_just_pressed("special") and can_special():
		execute_special_attack()
		return

	# Punch
	if Input.is_action_just_pressed("punch") and can_attack():
		execute_punch()

	# Kick
	if Input.is_action_just_pressed("kick") and can_attack():
		execute_kick()

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and current_state != CharacterState.BLOCKING:
		velocity.y = JUMP_VELOCITY

func can_attack() -> bool:
	if current_state in [CharacterState.DEAD, CharacterState.PUNCHING, CharacterState.KICKING, CharacterState.SPECIAL, CharacterState.HURT, CharacterState.VICTORY]:
		return false
	if is_frozen:
		return false
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time < attack_cooldown:
		return false
	
	return true

func can_special() -> bool:
	if not can_attack():
		return false
	return (special_meter >= MAX_SPECIAL_METER)

# Combat Functions
func execute_punch() -> void:
	set_state(CharacterState.PUNCHING)
	last_attack_time = Time.get_ticks_msec() / 1000.0
	combo_count += 1
	emit_signal("combo_updated", combo_count)
	
	_ensure_target()
	if target_node and is_instance_valid(target_node):
		var dir = (target_node.global_position - global_position).normalized()
		dir.y = 0
		if dir.length() > 0.1:
			rotation.y = get_facing_rotation(dir)
	
	var punch_anim = "attack-melee-left" if combo_count % 2 == 1 else "attack-melee-right"
	play_animation(punch_anim, 0.08)
	
	var damage = BASE_PUNCH_DAMAGE * attack_multiplier
	if combo_count >= 3:
		damage *= 1.3
	
	check_and_apply_hit(PUNCH_RANGE, damage, "punch", 2.5)
	
	await get_tree().create_timer(0.26).timeout
	if current_state == CharacterState.PUNCHING:
		set_state(CharacterState.IDLE)
		play_animation("idle", ANIMATION_BLEND_TIME)

func execute_kick() -> void:
	set_state(CharacterState.KICKING)
	last_attack_time = Time.get_ticks_msec() / 1000.0
	combo_count += 1
	emit_signal("combo_updated", combo_count)
	
	_ensure_target()
	if target_node and is_instance_valid(target_node):
		var dir = (target_node.global_position - global_position).normalized()
		dir.y = 0
		if dir.length() > 0.1:
			rotation.y = get_facing_rotation(dir)
	
	var kick_anim = "attack-kick-left" if randf() > 0.5 else "attack-kick-right"
	play_animation(kick_anim, 0.08)
	
	var damage = BASE_KICK_DAMAGE * attack_multiplier
	check_and_apply_hit(KICK_RANGE, damage, "kick", 5.0)
	
	await get_tree().create_timer(0.35).timeout
	if current_state == CharacterState.KICKING:
		set_state(CharacterState.IDLE)
		play_animation("idle", ANIMATION_BLEND_TIME)

# Special Attack Logic
func execute_special_attack() -> void:
	set_state(CharacterState.SPECIAL)
	special_meter = 0.0
	emit_signal("special_meter_changed", special_meter, MAX_SPECIAL_METER)
	_ensure_target()
	
	if target_node and is_instance_valid(target_node):
		var dir = (target_node.global_position - global_position).normalized()
		dir.y = 0
		if dir.length() > 0.1:
			rotation.y = get_facing_rotation(dir)

	var fwd = get_forward_vector()
	var spawn_pos = global_position + Vector3(0, 1.1, 0) + fwd * 0.8
	var parent_scene = get_parent()

	match special_type:
		"fireball":
			play_animation("attack-melee-right", 0.08)
			var fb = PREFAB_FIREBALL.instantiate()
			parent_scene.add_child(fb)
			fb.global_position = spawn_pos
			fb.rotation.y = rotation.y
			fb.setup(self, target_node, fwd, 38.0 * attack_multiplier)
			
			await get_tree().create_timer(0.35).timeout
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

		"freeze":
			play_animation("attack-melee-left", 0.08)
			var ice = PREFAB_ICE_FREEZE.instantiate()
			parent_scene.add_child(ice)
			ice.global_position = spawn_pos
			ice.rotation.y = rotation.y
			ice.setup(self, target_node, fwd, 24.0 * attack_multiplier)
			
			await get_tree().create_timer(0.35).timeout
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

		"heal":
			play_animation("holding-both", 0.1)
			var aura = PREFAB_HEAL_AURA.instantiate()
			add_child(aura)
			aura.position = Vector3.ZERO
			aura.setup(self, 70.0)
			
			await get_tree().create_timer(0.55).timeout
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

		"gunfire":
			play_animation("attack-melee-right", 0.05)
			var shot = PREFAB_GUNFIRE.instantiate()
			parent_scene.add_child(shot)
			shot.global_position = spawn_pos
			shot.rotation.y = rotation.y
			shot.setup(self, target_node, fwd, 32.0 * attack_multiplier)
			
			await get_tree().create_timer(0.25).timeout
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

		"lightning":
			play_animation("emote-yes", 0.1)
			if target_node and is_instance_valid(target_node):
				var bolt = PREFAB_LIGHTNING.instantiate()
				parent_scene.add_child(bolt)
				bolt.setup(self, target_node, 38.0 * attack_multiplier)
			
			await get_tree().create_timer(0.4).timeout
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

		"ground_smash":
			play_animation("attack-kick-left", 0.08)
			await get_tree().create_timer(0.18).timeout
			var slam = PREFAB_GROUND_SMASH.instantiate()
			parent_scene.add_child(slam)
			slam.global_position = global_position
			slam.setup(self, target_node, 34.0 * attack_multiplier)
			
			await get_tree().create_timer(0.35).timeout
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

		"laser":
			play_animation("holding-both", 0.1)
			var beam = PREFAB_LASER_BEAM.instantiate()
			parent_scene.add_child(beam)
			beam.global_position = spawn_pos
			beam.rotation.y = rotation.y
			beam.setup(self, target_node, fwd, 36.0 * attack_multiplier)
			
			await get_tree().create_timer(0.4).timeout
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

		"shield":
			play_animation("holding-both", 0.1)
			var dome = PREFAB_SHIELD_DOME.instantiate()
			add_child(dome)
			dome.position = Vector3.ZERO
			dome.setup(self, 100.0)
			
			await get_tree().create_timer(0.5).timeout
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

		"teleport":
			play_animation("emote-no", 0.05)
			visible = false
			await get_tree().create_timer(0.12).timeout
			if target_node and is_instance_valid(target_node):
				var opp_fwd = target_node.get_forward_vector()
				var behind_pos = target_node.global_position - opp_fwd * 1.5
				behind_pos.x = clamp(behind_pos.x, -RING_LIMIT, RING_LIMIT)
				behind_pos.z = clamp(behind_pos.z, -RING_LIMIT, RING_LIMIT)
				global_position = behind_pos
				var dir = (target_node.global_position - global_position).normalized()
				rotation.y = get_facing_rotation(dir)
			visible = true
			play_animation("attack-melee-right", 0.05)
			check_and_apply_hit(2.8, 34.0 * attack_multiplier, "teleport_strike", 6.0)
			
			await get_tree().create_timer(0.3).timeout
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

		"tornado":
			for i in range(4):
				play_animation("attack-melee-right" if i % 2 == 0 else "attack-melee-left", 0.05)
				rotation.y += deg_to_rad(90)
				check_and_apply_hit(2.8, 9.0 * attack_multiplier, "tornado", 3.0)
				await get_tree().create_timer(0.08).timeout
			
			if current_state == CharacterState.SPECIAL:
				set_state(CharacterState.IDLE)
				play_animation("idle", ANIMATION_BLEND_TIME)

func freeze_in_place(duration: float = 1.8) -> void:
	is_frozen = true
	if animation_player:
		animation_player.pause()
	
	await get_tree().create_timer(duration).timeout
	is_frozen = false
	if animation_player:
		animation_player.play()

func _ensure_target() -> void:
	if not target_node or not is_instance_valid(target_node):
		var fighters = get_tree().get_nodes_in_group("fighters")
		for f in fighters:
			if f != self and is_instance_valid(f):
				target_node = f
				break

func check_and_apply_hit(max_range: float, raw_damage: float, attack_type: String, knockback_power: float) -> void:
	_ensure_target()
	if not target_node or not is_instance_valid(target_node):
		return
	if target_node.current_state == CharacterState.DEAD:
		return
	
	var distance = global_position.distance_to(target_node.global_position)
	if distance <= max_range:
		var forward = get_forward_vector()
		var dir_to_target = (target_node.global_position - global_position).normalized()
		var dot = forward.dot(dir_to_target)
		
		if dot > -0.2 or distance <= 2.0:
			var hit_dir = dir_to_target
			target_node.take_damage(raw_damage, attack_type, hit_dir, knockback_power)
			add_special_meter(1.0) # Adds 1 hit towards 10-hit super meter!
			emit_signal("character_hit", raw_damage, combo_count >= 3, target_node.global_position + Vector3(0, 1.2, 0))

func start_blocking() -> void:
	if current_state not in [CharacterState.DEAD, CharacterState.PUNCHING, CharacterState.KICKING, CharacterState.SPECIAL, CharacterState.HURT]:
		is_blocking = true
		set_state(CharacterState.BLOCKING)
		play_animation("holding-both", 0.1)

func stop_blocking() -> void:
	is_blocking = false
	if current_state == CharacterState.BLOCKING:
		set_state(CharacterState.IDLE)
		play_animation("idle", ANIMATION_BLEND_TIME)

func take_damage(raw_damage: float, attack_type: String = "unknown", from_dir: Vector3 = Vector3.ZERO, knockback: float = 3.0) -> void:
	if current_state == CharacterState.DEAD:
		return
	
	var def = max(0.4, defense_multiplier)
	var actual_damage = raw_damage / def
	
	# Shield absorption
	if shield_hp > 0:
		if shield_hp >= actual_damage:
			shield_hp -= actual_damage
			return
		else:
			actual_damage -= shield_hp
			shield_hp = 0.0
	
	# Apply guard damage reduction
	if is_blocking:
		actual_damage *= BLOCK_DAMAGE_RATIO
		if from_dir.length() > 0.1:
			velocity += from_dir * (knockback * 0.4)
	else:
		if from_dir.length() > 0.1:
			velocity += from_dir * knockback
		combo_count = 0
		emit_signal("combo_updated", 0)
	
	# Gain 0.5 meter when taking damage
	add_special_meter(0.5)
	
	health -= actual_damage
	health = max(health, 0.0)
	emit_signal("health_changed", health, max_health)
	
	if health <= 0.0:
		die()
	else:
		if not is_blocking and current_state != CharacterState.SPECIAL:
			trigger_hurt_reaction()

func trigger_hurt_reaction() -> void:
	set_state(CharacterState.HURT)
	play_animation("emote-no", 0.05)
	
	await get_tree().create_timer(0.22).timeout
	if current_state == CharacterState.HURT:
		set_state(CharacterState.IDLE)
		play_animation("idle", ANIMATION_BLEND_TIME)

func die() -> void:
	set_state(CharacterState.DEAD)
	is_blocking = false
	is_frozen = false
	find_and_cache_animation_player()
	if animation_player:
		animation_player.speed_scale = 0.35
	play_animation("die", 0.15)
	emit_signal("character_died", self)
	
	if target_node and is_instance_valid(target_node) and target_node.current_state != CharacterState.DEAD:
		target_node.trigger_victory()

func trigger_victory() -> void:
	set_state(CharacterState.VICTORY)
	velocity = Vector3.ZERO
	if animation_player:
		animation_player.speed_scale = 1.0
	play_animation("emote-yes", 0.15)

func play_animation(anim_name: String, blend_time: float = ANIMATION_BLEND_TIME) -> void:
	find_and_cache_animation_player()
	if not animation_player:
		return
	
	if anim_name != "die":
		var p = get_parent()
		if not (p and p.name == "CharacterShowcase"):
			animation_player.speed_scale = 1.0
	
	if animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name or not animation_player.is_playing():
			animation_player.play(anim_name, blend_time)
	else:
		if animation_player.has_animation("idle"):
			animation_player.play("idle", blend_time)

func set_state(new_state: CharacterState) -> void:
	if current_state != new_state:
		current_state = new_state
		emit_signal("state_changed", new_state)

func set_target(target: CharacterBody3D) -> void:
	target_node = target
