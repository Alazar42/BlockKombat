extends Node3D

@onready var character1: CharacterBody3D = $Character1
@onready var character2: CharacterBody3D = $Character2
@onready var char_select_ui = $CanvasLayer/CharacterSelectUI

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

func set_combatant_character(char_data: Dictionary) -> void:
	Data.player2_character = char_data
	if character2 and is_instance_valid(character2):
		if char_data.has("texture"):
			character2.set_character_texture(char_data.texture)
		elif char_data.has("key"):
			character2.character_type = char_data.key
			character2.load_character()
