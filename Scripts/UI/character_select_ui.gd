extends Control

@onready var fighter_name: Label = $FighterInfo/VBoxContainer/FighterName
@onready var fighter_stats: VBoxContainer = $FighterInfo/VBoxContainer/FighterStats
@onready var combatant_name: Label = $KombatantInfo/VBoxContainer/CombatantName
@onready var combatant_stats: VBoxContainer = $KombatantInfo/VBoxContainer/CombatantStats
@onready var fighters_list: ItemList = $CharacterSelectControl/Panel/FightersList
@onready var choose_label: Label = $BottomChooseLabel

# Tab Buttons for P1 and AI selection
@onready var p1_tab_btn: Button = $SelectorTabs/P1TabButton
@onready var ai_tab_btn: Button = $SelectorTabs/AITabButton

# Active selection mode: "P1" or "AI"
var current_selection_mode: String = "P1"

var selected_p1_index: int = 0
var selected_p2_index: int = 5

func _ready() -> void:
	# Populate ItemList with 18 characters
	fighters_list.clear()
	for i in range(Data.characters.size()):
		var char_data = Data.characters[i]
		var icon_tex = load(char_data.icon) if ResourceLoader.exists(char_data.icon) else null
		fighters_list.add_item(char_data.name, icon_tex)

	# Initial character setups
	_update_p1_selection(selected_p1_index)
	_update_p2_selection(selected_p2_index)
	
	_on_p1_tab_button_pressed()

func _get_showcase_scene() -> Node:
	var p = get_parent()
	while p:
		if p.has_method("set_fighter_character"):
			return p
		p = p.get_parent()
	return null

func _update_p1_selection(index: int) -> void:
	selected_p1_index = index
	var char_data = Data.characters[index]
	update_ui(char_data, "Fighter")
	
	var showcase = _get_showcase_scene()
	if showcase:
		showcase.set_fighter_character(char_data)

func _update_p2_selection(index: int) -> void:
	selected_p2_index = index
	var char_data = Data.characters[index]
	update_ui(char_data, "Combatant")
	
	var showcase = _get_showcase_scene()
	if showcase:
		showcase.set_combatant_character(char_data)

func _on_p1_tab_button_pressed() -> void:
	current_selection_mode = "P1"
	choose_label.text = "SELECT YOUR FIGHTER (PLAYER 1)"
	p1_tab_btn.modulate = Color(1.2, 1.2, 1.2, 1.0)
	ai_tab_btn.modulate = Color(0.7, 0.7, 0.7, 0.8)
	fighters_list.select(selected_p1_index)
	fighters_list.ensure_current_is_visible()

func _on_ai_tab_button_pressed() -> void:
	current_selection_mode = "AI"
	choose_label.text = "SELECT OPPONENT COMBATANT (AI)"
	p1_tab_btn.modulate = Color(0.7, 0.7, 0.7, 0.8)
	ai_tab_btn.modulate = Color(1.2, 1.2, 1.2, 1.0)
	fighters_list.select(selected_p2_index)
	fighters_list.ensure_current_is_visible()

func _on_fighters_list_item_selected(index: int) -> void:
	if current_selection_mode == "P1":
		_update_p1_selection(index)
	else:
		_update_p2_selection(index)

func _on_fighters_list_item_activated(index: int) -> void:
	if current_selection_mode == "P1":
		_update_p1_selection(index)
		_on_ai_tab_button_pressed()
	else:
		_update_p2_selection(index)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		if current_selection_mode == "P1":
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
