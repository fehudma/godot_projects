extends Control
#=======================CONSTs
const CHARACTER_NAMES: Array[String] = [
	"Arin",
	"Mira",
	"Doran",
	"Lysa"
]
#=======================VARs
var character_name: String = "Unknown"
var attack: int = 10
var defense: int = 5
var health: int = 20
var charcter: Dictionary = {}

#=======================OnReadies
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var attack_label: Label = $VBoxContainer/AttackLabel
@onready var defense_label: Label = $VBoxContainer/DefenseLabel



#=======================HELPER FUNCTIONs
#update ui
func update_stats_display() -> void:
	name_label.text = "Name: " + str(character_name)
	attack_label.text = "Attack: " + str(attack)
	defense_label.text = "Defense: " + str(defense)
	health_label.text = "Health: " + str(health)

#character generation
func generate_character() -> void:
	character_name = CHARACTER_NAMES.pick_random()
	health = randi_range(20, 40)
	attack = randi_range(5, 15)
	defense = randi_range(3, 10)

#=======================INIT
func _ready() -> void:
	update_stats_display()


#=======================SIGNALs
func _on_recruit_button_pressed() -> void:
	generate_character()
	update_stats_display()
