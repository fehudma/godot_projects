extends Control
#=======================CONSTs
const CHARACTER_NAMES: Array[String] = [
	"Arin",
	"Mira",
	"Doran",
	"Lysa"
]

const MIN_ATTACK: int = 5
const MAX_ATTACK: int = 15

const MIN_DEFENSE: int = 3
const MAX_DEFENSE: int = 10

const MIN_HEALTH: int = 20
const MAX_HEALTH: int = 40
#=======================VARs
var character: Dictionary = {
	"name": "Unknown",
	"level": 1,
	"experience": 0,
	"attack": 0,
	"defense": 0,
	"health": 0
}

var has_character: bool = false
#=======================OnReadies
@onready var recruit_button: Button = $RecruitButton
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var experience_label: Label = $VBoxContainer/ExperienceLabel
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var attack_label: Label = $VBoxContainer/AttackLabel
@onready var defense_label: Label = $VBoxContainer/DefenseLabel




#=======================HELPER FUNCTIONs
#update ui
func update_stats_display() -> void:
	if not has_character:
		name_label.text = "No character recruited"
		experience_label.text = "XP: -"
		level_label.text = "Level: " + str(character["level"])
		health_label.text = "Health: -"
		attack_label.text = "Attack: -"
		defense_label.text = "Defense: -"
		return
	
	name_label.text = "Name: " + str(character["name"])
	level_label.text = "Level: " + str(character["level"])
	experience_label.text = "XP: " + str(character["experience"])
	health_label.text = "Health: " + str(character["health"])
	attack_label.text = "Attack: " + str(character["attack"])
	defense_label.text = "Defense: " + str(character["defense"])

#character generation
func generate_character() -> void:
	character["name"] = CHARACTER_NAMES.pick_random()
	character["level"] = 1
	character["experience"] = 0
	character["health"] = randi_range(MIN_HEALTH, MAX_HEALTH)
	character["attack"] = randi_range(MIN_ATTACK, MAX_ATTACK)
	character["defense"] = randi_range(MIN_DEFENSE, MAX_DEFENSE)
	has_character = true
	update_recruit_button()
	print(character)

#recruit button state
func update_recruit_button() -> void:
	recruit_button.disabled = has_character
#=======================INIT
func _ready() -> void:
	update_stats_display()
	update_recruit_button()


#=======================SIGNALs
func _on_recruit_button_pressed() -> void:
	if has_character:
		return

	generate_character()
	update_stats_display()
