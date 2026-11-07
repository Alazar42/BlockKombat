extends Node3D

@onready var character1: CharacterBody3D = $Character1
@onready var character2: CharacterBody3D = $Character2
@onready var char_select_ui = $CanvasLayer/CharacterSelectUI

const SHOWCASE_ANIM_SPEED: float = 0.55

func _ready() -> void:
	if Data.player1_character.is_empty():
		Data.player1_character = Data.characters[0]
	if Data.player2_character.is_empty():
		Data.player2_character = Data.characters[5]

	set_fighter_character(Data.player1_character)
	set_combatant_character(Data.player2_character)

func set_fighter_character(char_data: Dictionary) -> void:
	Data.player1_character = char_data
	if character1 and is_instance_valid(character1):
		if char_data.has("texture"):
			character1.set_character_texture(char_data.texture)
		elif char_data.has("key"):
			character1.character_type = char_data.key
			character1.load_character()
		
		_apply_showcase_animation(character1, "idle", SHOWCASE_ANIM_SPEED)

func set_combatant_character(char_data: Dictionary) -> void:
	Data.player2_character = char_data
	if character2 and is_instance_valid(character2):
		if char_data.has("texture"):
			character2.set_character_texture(char_data.texture)
		elif char_data.has("key"):
			character2.character_type = char_data.key
			character2.load_character()
		
		_apply_showcase_animation(character2, "idle", SHOWCASE_ANIM_SPEED)

func _apply_showcase_animation(char_body: CharacterBody3D, anim_name: String, speed: float) -> void:
	if not char_body:
		return
	
	if char_body.has_method("find_and_cache_animation_player"):
		char_body.find_and_cache_animation_player()
	
	var anim_player: AnimationPlayer = char_body.get("animation_player")
	if not anim_player:
		anim_player = char_body.find_child("AnimationPlayer", true, false)
	
	if anim_player:
		anim_player.speed_scale = speed
		if anim_player.has_animation(anim_name):
			var anim = anim_player.get_animation(anim_name)
			if anim:
				anim.loop_mode = Animation.LOOP_LINEAR
			anim_player.play(anim_name, 0.25)
