extends Control

@onready var fighter_name: Label = $FighterInfo/VBoxContainer/FighterName
@onready var fighter_stats: VBoxContainer = $FighterInfo/VBoxContainer/FighterStats

@onready var combatant_name: Label = $KombatantInfo/VBoxContainer/CombatantName
@onready var combatant_stats: VBoxContainer = $KombatantInfo/VBoxContainer/CombatantStats

@onready var fighter_panel: Panel = $FighterInfo
@onready var combatant_panel: Panel = $KombatantInfo
@onready var bottom_label: Label = $BottomChooseLabel
@onready var fighters_list: ItemList = $CharacterSelectControl/Panel/FightersList

@onready var p1_tab_btn: Button = $SelectorTabs/P1TabButton
@onready var ai_tab_btn: Button = $SelectorTabs/AITabButton
@onready var start_fight_btn: Button = $StartFightButton

var character_node1: CharacterBody3D
var character_node2: CharacterBody3D

var characters: Array = [
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
]

var current_character_chooser: String = "Player1"

func _ready() -> void:
	# Find 3D preview character nodes in showcase scene
	character_node1 = get_parent().get_parent().get_node_or_null("Character1")
	character_node2 = get_parent().get_parent().get_node_or_null("Character2")
	if not character_node1:
		character_node1 = get_tree().current_scene.get_node_or_null("Character1")
	if not character_node2:
		character_node2 = get_tree().current_scene.get_node_or_null("Character2")

	# Initialize default characters
	if Data.player1_character.is_empty():
		Data.player1_character = Data.characters[0]
	if Data.player2_character.is_empty():
		Data.player2_character = Data.characters[5]

	if character_node1:
		character_node1.character_type = characters[0]
		character_node1.load_character()
		character_node1.play_animation("emote-yes", 0.1)
			
	if character_node2:
		character_node2.character_type = characters[5]
		character_node2.load_character()
		character_node2.play_animation("idle", 0.1)

	update_ui(Data.player1_character, "Fighter")
	update_ui(Data.player2_character, "Combatant")
	
	_update_active_chooser_visuals()
	
	fighters_list.select(0)
	fighters_list.grab_focus()

func _update_active_chooser_visuals() -> void:
	if current_character_chooser == "Player1":
		bottom_label.text = "SELECT YOUR FIGHTER (PLAYER 1)"
		if p1_tab_btn:
			p1_tab_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		if ai_tab_btn:
			ai_tab_btn.modulate = Color(0.6, 0.6, 0.6, 0.8)
		fighter_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
		combatant_panel.modulate = Color(0.65, 0.65, 0.65, 0.8)
	else:
		bottom_label.text = "SELECT ENEMY COMBATANT (AI)"
		if p1_tab_btn:
			p1_tab_btn.modulate = Color(0.6, 0.6, 0.6, 0.8)
		if ai_tab_btn:
			ai_tab_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		fighter_panel.modulate = Color(0.65, 0.65, 0.65, 0.8)
		combatant_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_fighters_list_item_selected(index: int) -> void:
	if index < 0 or index >= Data.characters.size():
		return
		
	if current_character_chooser == "Player1":
		Data.player1_character = Data.characters[index]
		if character_node1:
			character_node1.character_type = characters[index]
			character_node1.load_character()
			character_node1.play_animation("emote-yes", 0.1)
		update_ui(Data.player1_character, "Fighter")
	else:
		Data.player2_character = Data.characters[index]
		if character_node2:
			character_node2.character_type = characters[index]
			character_node2.load_character()
			character_node2.play_animation("emote-yes", 0.1)
		update_ui(Data.player2_character, "Combatant")

func _on_fighters_list_item_activated(index: int) -> void:
	if current_character_chooser == "Player1":
		_set_chooser("Player2")
		var p2_idx = Data.player2_character.get("id", 5)
		fighters_list.select(p2_idx)
	else:
		_on_start_fight_button_pressed()

func _on_p1_tab_button_pressed() -> void:
	_set_chooser("Player1")
	var p1_idx = Data.player1_character.get("id", 0)
	fighters_list.select(p1_idx)

func _on_ai_tab_button_pressed() -> void:
	_set_chooser("Player2")
	var p2_idx = Data.player2_character.get("id", 5)
	fighters_list.select(p2_idx)

func _set_chooser(chooser: String) -> void:
	current_character_chooser = chooser
	_update_active_chooser_visuals()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_player_select") or event.is_action_pressed("ui_cancel"):
		if current_character_chooser == "Player2":
			_set_chooser("Player1")
			var p1_idx = Data.player1_character.get("id", 0)
			fighters_list.select(p1_idx)
	elif event.is_action_pressed("ui_focus_next"):
		if current_character_chooser == "Player1":
			_on_ai_tab_button_pressed()
		else:
			_on_p1_tab_button_pressed()

func update_ui(character: Dictionary, player_type: String) -> void:
	var spec_name = character.get("special_name", "Special")
	var spec_desc = character.get("special_desc", "")
	var ability_text = "ABILITY: " + spec_name.to_upper()
	if not spec_desc.is_empty():
		ability_text += " (" + spec_desc + ")"
	
	match player_type:
		"Fighter":
			if fighter_name:
				fighter_name.text = character.name
			if fighter_stats:
				fighter_stats.get_node("AttackStatItem/StatProgress").value = character.attack.to_int()
				fighter_stats.get_node("DefenseStatItem/StatProgress").value = character.defense.to_int()
				fighter_stats.get_node("SpeedStatItem/StatProgress").value = character.speed.to_int()
				fighter_stats.get_node("SpecialStatItem/StatProgress").value = character.special.to_int()
				if fighter_stats.has_node("SpecialAbilityLabel"):
					fighter_stats.get_node("SpecialAbilityLabel").text = ability_text
		"Combatant":
			if combatant_name:
				combatant_name.text = character.name
			if combatant_stats:
				combatant_stats.get_node("AttackStatItem/StatProgress").value = character.attack.to_int()
				combatant_stats.get_node("DefenseStatItem/StatProgress").value = character.defense.to_int()
				combatant_stats.get_node("SpeedStatItem/StatProgress").value = character.speed.to_int()
				if combatant_stats.has_node("SpecialStatItem/SpecialProgress"):
					combatant_stats.get_node("SpecialStatItem/SpecialProgress").value = character.special.to_int()
				elif combatant_stats.has_node("SpecialStatItem/StatProgress"):
					combatant_stats.get_node("SpecialStatItem/StatProgress").value = character.special.to_int()
				if combatant_stats.has_node("SpecialAbilityLabel"):
					combatant_stats.get_node("SpecialAbilityLabel").text = ability_text

func _on_start_fight_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/BoxingRing/boxing_ring.tscn")

func _on_menu_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

