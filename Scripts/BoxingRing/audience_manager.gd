extends Node3D

const PREFAB_CHARACTER = preload("res://Scenes/Characters/character.tscn")

const AUDIENCE_TEXTURES := [
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-a.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-b.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-c.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-d.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-e.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-f.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-g.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-h.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-i.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-j.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-k.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-l.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-m.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-n.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-o.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-p.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-q.png",
	"res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-r.png"
]

const STANDING_ANIMS := [
	"idle",
	"emote-yes",
	"holding-both",
	"emote-no",
	"interact-left",
	"interact-right",
	"walk",
	"attack-melee-right"
]

var audience_anim_players: Array[AnimationPlayer] = []
var next_gesture_time: float = 0.0

func _ready() -> void:
	_build_bleachers()
	_spawn_spectators()

func _build_bleachers() -> void:
	var bleacher_mat = StandardMaterial3D.new()
	bleacher_mat.albedo_color = Color(0.12, 0.12, 0.14, 1.0)
	bleacher_mat.roughness = 0.8
	
	var box_mesh = BoxMesh.new()
	box_mesh.material = bleacher_mat
	
	var sides = [
		{"pos": Vector3(0, 0, -9.8), "rot_y": 0, "size": Vector3(18.0, 1.0, 3.5)},
		{"pos": Vector3(0, 0, 9.8), "rot_y": PI, "size": Vector3(18.0, 1.0, 3.5)},
		{"pos": Vector3(-10.5, 0, 0), "rot_y": PI * 0.5, "size": Vector3(18.0, 1.0, 3.5)},
		{"pos": Vector3(10.5, 0, 0), "rot_y": -PI * 0.5, "size": Vector3(18.0, 1.0, 3.5)}
	]
	
	for side in sides:
		# Tier 1 (Low)
		var tier1 = MeshInstance3D.new()
		tier1.mesh = box_mesh
		tier1.scale = Vector3(side.size.x, 0.8, 1.6)
		tier1.position = side.pos + Vector3(0, 0.4, 0)
		tier1.rotation.y = side.rot_y
		add_child(tier1)
		
		# Tier 2 (High)
		var outward_dir = (side.pos * Vector3(1, 0, 1)).normalized()
		var tier2 = MeshInstance3D.new()
		tier2.mesh = box_mesh
		tier2.scale = Vector3(side.size.x, 1.8, 1.6)
		tier2.position = side.pos + outward_dir * 1.5 + Vector3(0, 0.9, 0)
		tier2.rotation.y = side.rot_y
		add_child(tier2)

func _spawn_spectators() -> void:
	var spectator_slots: Array[Vector3] = []
	
	# North Side (Tier 1 & Tier 2)
	for x in [-6.5, -4.0, -1.5, 1.5, 4.0, 6.5]:
		spectator_slots.append(Vector3(x, 0.8, -9.2))
		spectator_slots.append(Vector3(x, 1.8, -10.8))
	
	# South Side
	for x in [-6.5, -4.0, -1.5, 1.5, 4.0, 6.5]:
		spectator_slots.append(Vector3(x, 0.8, 9.2))
		spectator_slots.append(Vector3(x, 1.8, 10.8))
	
	# West Side
	for z in [-5.0, -2.5, 0.0, 2.5, 5.0]:
		spectator_slots.append(Vector3(-9.8, 0.8, z))
		spectator_slots.append(Vector3(-11.4, 1.8, z))
	
	# East Side
	for z in [-5.0, -2.5, 0.0, 2.5, 5.0]:
		spectator_slots.append(Vector3(9.8, 0.8, z))
		spectator_slots.append(Vector3(11.4, 1.8, z))

	for pos in spectator_slots:
		var spectator = PREFAB_CHARACTER.instantiate()
		add_child(spectator)
		spectator.position = pos
		
		# Align model front (+Z) to point directly at the boxing ring center
		spectator.look_at(Vector3(0, 0.8, 0), Vector3.UP, true)
		
		# Disable gameplay physics and collision
		spectator.set_physics_process(false)
		spectator.set_process_input(false)
		var col = spectator.find_child("CollisionShape3D", true, false)
		if col:
			col.disabled = true
		
		# Assign random skin texture
		var tex_path = AUDIENCE_TEXTURES[randi() % AUDIENCE_TEXTURES.size()]
		if spectator.has_method("set_character_texture"):
			spectator.set_character_texture(tex_path)
		
		# Play diverse initial animation
		var anim_player = spectator.find_child("AnimationPlayer", true, false)
		if anim_player:
			_assign_random_animation(anim_player)
			audience_anim_players.append(anim_player)

func _assign_random_animation(anim_player: AnimationPlayer) -> void:
	var anim_choice = STANDING_ANIMS[randi() % STANDING_ANIMS.size()]
	if anim_player.has_animation(anim_choice):
		var anim = anim_player.get_animation(anim_choice)
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.speed_scale = randf_range(0.6, 1.2)
		anim_player.play(anim_choice, 0.25)
		if anim:
			anim_player.seek(randf_range(0.0, anim.length), true)

func _process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time >= next_gesture_time:
		next_gesture_time = current_time + randf_range(1.5, 3.0)
		if audience_anim_players.size() > 0:
			for _i in range(randi_range(2, 4)):
				var random_player = audience_anim_players[randi() % audience_anim_players.size()]
				if is_instance_valid(random_player):
					_assign_random_animation(random_player)

func trigger_crowd_cheer() -> void:
	for player in audience_anim_players:
		if is_instance_valid(player):
			var cheer_anim = "emote-yes" if randf() > 0.4 else "holding-both"
			if player.has_animation(cheer_anim):
				player.play(cheer_anim, 0.15)
				player.speed_scale = randf_range(1.1, 1.5)
