extends Control

@onready var p1_name_label: Label = $TopHUD/P1Container/P1Info/NameLabel
@onready var p1_hp_bar: ProgressBar = $TopHUD/P1Container/P1Info/HealthBar
@onready var p1_hp_lag_bar: ProgressBar = $TopHUD/P1Container/P1Info/HealthBar/LagBar
@onready var p1_icon: TextureRect = $TopHUD/P1Container/IconRect

@onready var p2_name_label: Label = $TopHUD/P2Container/P2Info/NameLabel
@onready var p2_hp_bar: ProgressBar = $TopHUD/P2Container/P2Info/HealthBar
@onready var p2_hp_lag_bar: ProgressBar = $TopHUD/P2Container/P2Info/HealthBar/LagBar
@onready var p2_icon: TextureRect = $TopHUD/P2Container/IconRect

@onready var timer_label: Label = $TopHUD/CenterContainer/TimerLabel
@onready var combo_label: Label = $ComboContainer/ComboLabel
@onready var ko_splash: Label = $KOSplash

@onready var game_over_panel: Panel = $GameOverPanel
@onready var result_title_label: Label = $GameOverPanel/VBoxContainer/ResultTitleLabel
@onready var winner_label: Label = $GameOverPanel/VBoxContainer/WinnerLabel
@onready var rematch_btn: Button = $GameOverPanel/VBoxContainer/ButtonGroup/RematchButton
@onready var char_select_btn: Button = $GameOverPanel/VBoxContainer/ButtonGroup/CharSelectButton
@onready var main_menu_btn: Button = $GameOverPanel/VBoxContainer/ButtonGroup/MainMenuButton

var round_time: float = 99.0
var is_game_over: bool = false
var p1_fighter: CharacterBody3D
var p2_combatant: CharacterBody3D

func _ready() -> void:
	game_over_panel.visible = false
	combo_label.visible = false
	if ko_splash:
		ko_splash.visible = false
	
	Engine.time_scale = 1.0
	
	rematch_btn.pressed.connect(_on_rematch_pressed)
	char_select_btn.pressed.connect(_on_char_select_pressed)
	if main_menu_btn:
		main_menu_btn.pressed.connect(_on_main_menu_pressed)

func initialize_hud(p1: CharacterBody3D, p2: CharacterBody3D, p1_data: Dictionary, p2_data: Dictionary) -> void:
	p1_fighter = p1
	p2_combatant = p2
	
	# Set P1 Info
	p1_name_label.text = p1_data.get("name", "Player 1")
	if p1_data.has("icon"):
		p1_icon.texture = load(p1_data.icon)
	p1_hp_bar.value = 100.0
	p1_hp_lag_bar.value = 100.0
	
	# Set P2 Info
	p2_name_label.text = p2_data.get("name", "Combatant AI")
	if p2_data.has("icon"):
		p2_icon.texture = load(p2_data.icon)
	p2_hp_bar.value = 100.0
	p2_hp_lag_bar.value = 100.0
	
	# Connect signals
	if p1:
		p1.health_changed.connect(_on_p1_health_changed)
		p1.combo_updated.connect(_on_p1_combo_updated)
		p1.character_died.connect(_on_character_died)
	if p2:
		p2.health_changed.connect(_on_p2_health_changed)
		p2.character_died.connect(_on_character_died)

func _process(delta: float) -> void:
	if is_game_over:
		return
	
	if round_time > 0:
		round_time -= delta
		timer_label.text = str(int(ceil(round_time)))
		if round_time <= 0:
			_on_time_out()
	
	# Smoothly interpolate HP lag bars
	if p1_hp_lag_bar.value > p1_hp_bar.value:
		p1_hp_lag_bar.value = move_toward(p1_hp_lag_bar.value, p1_hp_bar.value, delta * 35.0)
	if p2_hp_lag_bar.value > p2_hp_bar.value:
		p2_hp_lag_bar.value = move_toward(p2_hp_lag_bar.value, p2_hp_bar.value, delta * 35.0)

func _on_p1_health_changed(current: float, max_hp: float) -> void:
	var pct = (current / max_hp) * 100.0
	p1_hp_bar.value = pct

func _on_p2_health_changed(current: float, max_hp: float) -> void:
	var pct = (current / max_hp) * 100.0
	p2_hp_bar.value = pct

func _on_p1_combo_updated(combo_count: int) -> void:
	if combo_count >= 2:
		combo_label.text = str(combo_count) + " HITS COMBO!"
		combo_label.visible = true
		combo_label.scale = Vector2(1.2, 1.2)
		var tween = create_tween()
		tween.tween_property(combo_label, "scale", Vector2.ONE, 0.15)
	else:
		if combo_label.visible:
			var tween = create_tween()
			tween.tween_property(combo_label, "modulate:a", 0.0, 0.3)
			tween.tween_callback(func(): combo_label.visible = false; combo_label.modulate.a = 1.0)

func _on_character_died(dead_char: CharacterBody3D) -> void:
	if is_game_over:
		return
	is_game_over = true
	
	var is_p1_winner = (dead_char != p1_fighter)
	
	Engine.time_scale = 0.35
	
	if ko_splash:
		ko_splash.visible = true
		ko_splash.scale = Vector2(2.0, 2.0)
		ko_splash.modulate.a = 1.0
		var ko_tween = create_tween().set_ignore_time_scale(true)
		ko_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		ko_tween.tween_property(ko_splash, "scale", Vector2.ONE, 0.3)
	
	await get_tree().create_timer(1.3, true, false, true).timeout
	
	Engine.time_scale = 1.0
	
	if ko_splash:
		var fade_tween = create_tween()
		fade_tween.tween_property(ko_splash, "modulate:a", 0.0, 0.25)
		fade_tween.tween_callback(func(): ko_splash.visible = false)
	
	show_game_over(is_p1_winner, "K.O.!")

func _on_time_out() -> void:
	is_game_over = true
	var is_p1_winner = (p1_hp_bar.value >= p2_hp_bar.value)
	show_game_over(is_p1_winner, "TIME UP!")

func show_game_over(is_p1_winner: bool, title: String) -> void:
	game_over_panel.visible = true
	result_title_label.text = title
	
	if is_p1_winner:
		winner_label.text = "YOU WIN!"
		winner_label.modulate = Color(1.0, 0.92, 0.2, 1.0)
	else:
		winner_label.text = "YOU LOSE!"
		winner_label.modulate = Color(1.0, 0.3, 0.3, 1.0)
	
	rematch_btn.grab_focus()

func _on_rematch_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func _on_char_select_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/Characters/character_showcase.tscn")

func _on_main_menu_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
