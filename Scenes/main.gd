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
	"health": 0,
	"weapon": {},
	"armor": {}
}

var has_character: bool = false

var test_item: Dictionary = {
	"slot": "weapon",
	"name": "Rusty Sword",
	"attack_bonus": 2,
	"defense_bonus": 0,
	"health_bonus": 0
}

var test_armor: Dictionary = {
	"slot": "armor",
	"name": "Worn Armor",
	"attack_bonus": 0,
	"defense_bonus": 2,
	"health_bonus": 5,
}

var item_pool: Array[Dictionary] = [
	test_item,
	test_armor
]

var inventory: Array[Dictionary] = [
	
]
#=======================OnReadies
@onready var recruit_button: Button = $VBoxContainer2/RecruitButton
@onready var add_item_button: Button = $VBoxContainer2/AddItemButton
@onready var equip_weapon_button: Button = $VBoxContainer2/EquipWeaponButton


@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var experience_label: Label = $VBoxContainer/ExperienceLabel
@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var attack_label: Label = $VBoxContainer/AttackLabel
@onready var defense_label: Label = $VBoxContainer/DefenseLabel
@onready var inventory_count_label: Label = $VBoxContainer/InventoryCountLabel
@onready var last_item_label: Label = $VBoxContainer/LastItemLabel
@onready var equipped_weapon_label: Label = $VBoxContainer/EquippedWeaponLabel




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

#Pick a random item from the pool
func get_random_item() -> Dictionary:
	return item_pool.pick_random()

#Add one random item to inventory
func add_random_item_to_inventory() -> void:
	var item: Dictionary = get_random_item()
	inventory.append(item)
	last_item_label.text = "Last item: " + str(item["name"]) + " (" + str(item["slot"]) + ")"

#Show inventory size in the UI
func update_inventory_display() -> void:
	inventory_count_label.text = "Items: " + str(inventory.size())

#Equip a weapon manually from inventory
func equip_first_weapon() -> void:
	if inventory.is_empty():
		return

	var item: Dictionary = inventory[0]

	if item["slot"] != "weapon":
		return

	character["weapon"] = item

#Show the equipped weapon name
func update_equipment_display() -> void:
	if character["weapon"].is_empty():
		equipped_weapon_label.text = "Weapon: None"
		return

	equipped_weapon_label.text = "Weapon: " + str(character["weapon"]["name"])
#=======================OTHER
#nothing here yet...
#=======================INIT
func _ready() -> void:
	update_stats_display()
	update_recruit_button()
	update_inventory_display()


#=======================SIGNALs
func _on_recruit_button_pressed() -> void:
	if has_character:
		return

	generate_character()
	update_stats_display()


func _on_add_item_button_pressed() -> void:
	add_random_item_to_inventory()
	update_inventory_display()


func _on_test_button_pressed() -> void:
	print(character["weapon"])


func _on_equip_weapon_button_pressed() -> void:
	equip_first_weapon()
	update_equipment_display()
