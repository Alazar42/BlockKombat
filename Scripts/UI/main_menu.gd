extends Control

@onready var start_game_btn: Button = $MenuContainer/VBoxContainer/ButtonGroup/StartGameButton
@onready var quick_fight_btn: Button = $MenuContainer/VBoxContainer/ButtonGroup/QuickFightButton
@onready var controls_btn: Button = $MenuContainer/VBoxContainer/ButtonGroup/ControlsButton
@onready var quit_btn: Button = $MenuContainer/VBoxContainer/ButtonGroup/QuitButton

@onready var controls_modal: Panel = $ControlsModal
@onready var close_controls_btn: Button = $ControlsModal/VBoxContainer/CloseControlsButton

func _ready() -> void:
	# Ensure engine time scale is normal
	Engine.time_scale = 1.0
	
	if controls_modal:
		controls_modal.visible = false
	
	start_game_btn.pressed.connect(_on_start_game_pressed)
	quick_fight_btn.pressed.connect(_on_quick_fight_pressed)
	controls_btn.pressed.connect(_on_controls_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	if close_controls_btn:
		close_controls_btn.pressed.connect(_on_close_controls_pressed)
	
	start_game_btn.grab_focus()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Characters/character_showcase.tscn")

func _on_quick_fight_pressed() -> void:
	# Randomize default fighters
	if Data.characters.size() >= 2:
		var p1_idx = randi() % Data.characters.size()
		var p2_idx = randi() % Data.characters.size()
		while p2_idx == p1_idx and Data.characters.size() > 1:
			p2_idx = randi() % Data.characters.size()
		Data.player1_character = Data.characters[p1_idx]
		Data.player2_character = Data.characters[p2_idx]
	get_tree().change_scene_to_file("res://Scenes/BoxingRing/boxing_ring.tscn")

func _on_controls_pressed() -> void:
	if controls_modal:
		controls_modal.visible = true
		if close_controls_btn:
			close_controls_btn.grab_focus()

func _on_close_controls_pressed() -> void:
	if controls_modal:
		controls_modal.visible = false
		controls_btn.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()
