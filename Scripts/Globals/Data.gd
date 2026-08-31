extends Node

var characters: Array[Dictionary] = [
	{
		"id": 0,
		"key": "character_a",
		"name": "Block Titan",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-a.png",
		"icon": "res://Assets/UI/CharacterIcons/1.jpg",
		"attack": "90",
		"defense": "85",
		"speed": "70"
	},
	{
		"id": 1,
		"key": "character_b",
		"name": "Iron Brawler",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-b.png",
		"icon": "res://Assets/UI/CharacterIcons/2.jpg",
		"attack": "75",
		"defense": "92",
		"speed": "65"
	},
	{
		"id": 2,
		"key": "character_c",
		"name": "Shadow Striker",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-c.png",
		"icon": "res://Assets/UI/CharacterIcons/3.jpg",
		"attack": "80",
		"defense": "68",
		"speed": "90"
	},
	{
		"id": 3,
		"key": "character_d",
		"name": "Hazard Hero",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-d.png",
		"icon": "res://Assets/UI/CharacterIcons/4.jpg",
		"attack": "85",
		"defense": "80",
		"speed": "75"
	},
	{
		"id": 4,
		"key": "character_e",
		"name": "Crimson Fist",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-e.png",
		"icon": "res://Assets/UI/CharacterIcons/5.jpg",
		"attack": "88",
		"defense": "72",
		"speed": "82"
	},
	{
		"id": 5,
		"key": "character_f",
		"name": "Cyber Champ",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-f.png",
		"icon": "res://Assets/UI/CharacterIcons/6.jpg",
		"attack": "82",
		"defense": "82",
		"speed": "80"
	},
	{
		"id": 6,
		"key": "character_g",
		"name": "Quantum Monk",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-g.png",
		"icon": "res://Assets/UI/CharacterIcons/7.jpg",
		"attack": "78",
		"defense": "86",
		"speed": "78"
	},
	{
		"id": 7,
		"key": "character_h",
		"name": "Robo Crusher",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-h.png",
		"icon": "res://Assets/UI/CharacterIcons/8.jpg",
		"attack": "94",
		"defense": "88",
		"speed": "60"
	},
	{
		"id": 8,
		"key": "character_i",
		"name": "Dr. Voltage",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-i.png",
		"icon": "res://Assets/UI/CharacterIcons/9.jpg",
		"attack": "84",
		"defense": "70",
		"speed": "88"
	},
	{
		"id": 9,
		"key": "character_j",
		"name": "Officer Slam",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-j.png",
		"icon": "res://Assets/UI/CharacterIcons/10.jpg",
		"attack": "82",
		"defense": "85",
		"speed": "74"
	},
	{
		"id": 10,
		"key": "character_k",
		"name": "Lumberjack Jack",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-k.png",
		"icon": "res://Assets/UI/CharacterIcons/11.jpg",
		"attack": "90",
		"defense": "78",
		"speed": "68"
	},
	{
		"id": 11,
		"key": "character_l",
		"name": "Zombie Bruiser",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-l.png",
		"icon": "res://Assets/UI/CharacterIcons/12.jpg",
		"attack": "86",
		"defense": "90",
		"speed": "58"
	},
	{
		"id": 12,
		"key": "character_m",
		"name": "Street Fighter",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-m.png",
		"icon": "res://Assets/UI/CharacterIcons/13.jpg",
		"attack": "84",
		"defense": "76",
		"speed": "84"
	},
	{
		"id": 13,
		"key": "character_n",
		"name": "Lotus Master",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-n.png",
		"icon": "res://Assets/UI/CharacterIcons/14.jpg",
		"attack": "76",
		"defense": "80",
		"speed": "92"
	},
	{
		"id": 14,
		"key": "character_o",
		"name": "Ghoul King",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-o.png",
		"icon": "res://Assets/UI/CharacterIcons/15.jpg",
		"attack": "89",
		"defense": "84",
		"speed": "66"
	},
	{
		"id": 15,
		"key": "character_p",
		"name": "Captain Hook",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-p.png",
		"icon": "res://Assets/UI/CharacterIcons/16.jpg",
		"attack": "87",
		"defense": "75",
		"speed": "79"
	},
	{
		"id": 16,
		"key": "character_q",
		"name": "Toxic Brawler",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-q.png",
		"icon": "res://Assets/UI/CharacterIcons/17.jpg",
		"attack": "86",
		"defense": "78",
		"speed": "76"
	},
	{
		"id": 17,
		"key": "character_r",
		"name": "Golden Champion",
		"texture": "res://Assets/Models/KennyBlockyCharacters/Models/FBX format/Textures/texture-r.png",
		"icon": "res://Assets/UI/CharacterIcons/18.jpg",
		"attack": "88",
		"defense": "88",
		"speed": "80"
	}
]

var player1_character: Dictionary = {}
var player2_character: Dictionary = {}
