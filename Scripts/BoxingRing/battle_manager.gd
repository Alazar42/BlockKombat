extends Node3D

@onready var p1_fighter: CharacterBody3D = $Characters/Fighter
@onready var p2_combatant: CharacterBody3D = $Characters/Combatant
@onready var battle_camera: Camera3D = $BattleCamera
@onready var battle_hud = $CanvasLayer/BattleHUD

func _ready() -> void:
	# Ensure default characters if starting directly in this scene
	if Data.player1_character.is_empty():
		Data.player1_character = Data.characters[0]
	if Data.player2_character.is_empty():
		Data.player2_character = Data.characters[5]

	# Set up Player 1 (Fighter)
	if p1_fighter:
		p1_fighter.is_ai = false
		p1_fighter.add_to_group("fighters")
		p1_fighter.apply_character_data(Data.player1_character)
		p1_fighter.global_position = Vector3(-3.2, 0.0, 0.0)
		p1_fighter.rotation.y = 0.0 # Face right (+X) towards opponent

	# Set up Player 2 (Combatant AI)
	if p2_combatant:
		p2_combatant.is_ai = true
		p2_combatant.add_to_group("fighters")
		p2_combatant.apply_character_data(Data.player2_character)
		p2_combatant.global_position = Vector3(3.2, 0.0, 0.0)
		p2_combatant.rotation.y = deg_to_rad(180) # Face left (-X) towards opponent
		
		# Attach Combatant AI controller if not already present
		if not p2_combatant.has_node("CombatantAI"):
			var ai_script = load("res://Scripts/Characters/combatant_ai.gd")
			if ai_script:
				var ai_node = Node.new()
				ai_node.name = "CombatantAI"
				ai_node.set_script(ai_script)
				p2_combatant.add_child(ai_node)

	# Cross-reference targets
	if p1_fighter and p2_combatant:
		p1_fighter.set_target(p2_combatant)
		p2_combatant.set_target(p1_fighter)

	# Hook camera shake on hits
	if battle_camera and battle_camera.has_method("add_trauma"):
		if p1_fighter:
			p1_fighter.character_hit.connect(func(_dmg, is_crit, _pos):
				battle_camera.add_trauma(0.35 if is_crit else 0.15)
			)
		if p2_combatant:
			p2_combatant.character_hit.connect(func(_dmg, is_crit, _pos):
				battle_camera.add_trauma(0.35 if is_crit else 0.15)
			)

	# Initialize Battle HUD
	if battle_hud and battle_hud.has_method("initialize_hud"):
		battle_hud.initialize_hud(p1_fighter, p2_combatant, Data.player1_character, Data.player2_character)
