#========================================
extends Control
#========================================
const STARTING_CLICKS: int = 0
const STARTING_CLICKS_PER_CLICK: int = 1
const STARTING_UPGRADE_COST: int = 3
const STARTING_UPGRADE_LEVEL: int = 0
const UPGRADE_MODIFIER: int = 1
const UPGRADE_COST_INCREASE: int = 2
const CLICKS_PER_CLICK_INCREASE: int = 1
const AUTO_CLICKER_UNLOCK_LEVEL: int = 3
const AUTO_CLICKER_COST_START: int = 5
const STARTING_PASSIVE_CLICKS_PER_TICK: int = 0
const AUTO_CLICKER_COST_INCREASE: int = 5
const PASSIVE_CLICKS_INCREASE: int = 1
const STARTING_AUTO_CLICKER_LEVEL: int = 0
const PASSIVE_INCOME_INTERVAL: float = 1.0
const SAVE_FILE_PATH: String = "user://savegame.json"
const REQUIRED_SAVE_KEYS: Array[String] = [
	"clicks",
	"clicks_per_click",
	"upgrade_cost",
	"upgrade_modifier",
	"passive_clicks_per_tick",
	"auto_clicker_cost",
	"auto_clicker_level"
]
#========================================
var clicks: int = STARTING_CLICKS
var clicks_per_click: int = STARTING_CLICKS_PER_CLICK
var upgrade_cost: int = STARTING_UPGRADE_COST
var upgrade_modifier: int = STARTING_UPGRADE_LEVEL
var passive_clicks_per_tick: int = STARTING_PASSIVE_CLICKS_PER_TICK
var auto_clicker_cost: int = AUTO_CLICKER_COST_START
var auto_clicker_level: int = STARTING_AUTO_CLICKER_LEVEL

#========================================
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var click_button: Button = $VBoxContainer/ClickButton
@onready var upgrade_button: Button = $VBoxContainer/UpgradeButton
@onready var reset_button: Button = $VBoxContainer/ResetButton
@onready var auto_clicker_button: Button = $VBoxContainer/AutoClickerButton
@onready var passive_income_timer: Timer = $PassiveIncomeTimer

#========================================
func update_ui() -> void:
	update_stats_label()
	update_upgrade_button()
	update_buy_auto_clicker_button()

#========================================helper functions
# 
func update_stats_label() -> void:
	stats_label.text = "Clicks: " + str(clicks) + "\nClick Power: " + str(clicks_per_click) + "\nAuto Click Power: " + str(passive_clicks_per_tick) + "\nAuto Clicker Level: " + str(auto_clicker_level)
#
func update_upgrade_button() -> void:
	upgrade_button.text = "Click Upgrade Cost: " + str(upgrade_cost)
	upgrade_button.disabled = not can_afford_upgrade()
#
func is_auto_clicker_unlocked() -> bool:
	if upgrade_modifier >= AUTO_CLICKER_UNLOCK_LEVEL:
		return true
	else:
		return false

#
func update_buy_auto_clicker_button() -> void:
	auto_clicker_button.text = "Auto Clicker Lv. " + str(auto_clicker_level) + " — Cost: " + str(auto_clicker_cost)
	auto_clicker_button.disabled = not can_afford_auto_clicker()
#
func start_passive_income_timer() -> void:
	if passive_income_timer.is_stopped():
		passive_income_timer.start()
#
func stop_passive_income_timer() -> void:
	passive_income_timer.stop()

func earn_passive_clicks() -> void:
	clicks += passive_clicks_per_tick

func restore_passive_income_timer() -> void:
	if auto_clicker_level > 0 and passive_clicks_per_tick > 0:
		start_passive_income_timer()
	else:
		stop_passive_income_timer()

func collect_save_data() -> Dictionary:
	var save_data: Dictionary = {}
	save_data["clicks"] = clicks
	save_data["clicks_per_click"] = clicks_per_click
	save_data["upgrade_cost"] = upgrade_cost
	save_data["upgrade_modifier"] = upgrade_modifier
	save_data["passive_clicks_per_tick"] = passive_clicks_per_tick
	save_data["auto_clicker_cost"] = auto_clicker_cost
	save_data["auto_clicker_level"] = auto_clicker_level
	return save_data

func reset_game_values() -> void:
	clicks = STARTING_CLICKS
	clicks_per_click = STARTING_CLICKS_PER_CLICK
	upgrade_cost= STARTING_UPGRADE_COST
	upgrade_modifier= STARTING_UPGRADE_LEVEL
	passive_clicks_per_tick = STARTING_PASSIVE_CLICKS_PER_TICK
	auto_clicker_cost= AUTO_CLICKER_COST_START
	auto_clicker_level = STARTING_AUTO_CLICKER_LEVEL

func reset_game() -> void:
	reset_game_values()
	stop_passive_income_timer()
	message_label.text = "Game Reset."
	update_ui()
#========================================
# initialize custom signal and on-click functionality
func _ready() -> void:
	click_button.pressed.connect(_on_click_button_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	passive_income_timer.wait_time = PASSIVE_INCOME_INTERVAL
	update_ui()

# on-click functionality
func _on_click_button_pressed() -> void:
	clicks += clicks_per_click
	print("Clicks: "+str(clicks) + "\nUpgrade: "+ str(upgrade_modifier))
	print(is_auto_clicker_unlocked())
	# check grammar for 1 click and multiple clicks
	show_click_message()
	update_ui()

# on-upgrade functionality
func _on_upgrade_button_pressed() -> void:
	if can_afford_upgrade():
		buy_upgrade()
		update_ui()

func _on_save_button_pressed() -> void:
	var save_data: Dictionary = collect_save_data()
	var json_text: String = JSON.stringify(save_data)
	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)

	if save_file == null:
		message_label.text = "Could not save game."
		return

	save_file.store_string(json_text)
	message_label.text = "Game saved."
	

func _on_load_button_pressed() -> void:	
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		message_label.text = "No Savefile exists"
		return
	
	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	
	if save_file == null:
		message_label.text = "Could not load game."
		return

	var json_text: String = save_file.get_as_text()
	
	var loaded_data: Variant = JSON.parse_string(json_text)
	
	if typeof(loaded_data) != TYPE_DICTIONARY:
		message_label.text = "Save file is invalid!"
		return
	
	var save_data: Dictionary = loaded_data
	#check (validate) dictionary for presence of keys
	if not save_data.has_all(REQUIRED_SAVE_KEYS):
		message_label.text = "Save file is missing data."
		return
	#check (validate) dictionary for correct data type inside of keys
	for key: String in REQUIRED_SAVE_KEYS:
		var value: Variant = save_data[key]
		
		if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
			message_label.text = "Save file contains invalid values."
			return
	
	clicks = int(save_data["clicks"])
	clicks_per_click = int(save_data["clicks_per_click"])
	upgrade_cost = int(save_data["upgrade_cost"])
	upgrade_modifier = int(save_data["upgrade_modifier"])
	passive_clicks_per_tick = int(save_data["passive_clicks_per_tick"])
	auto_clicker_cost = int(save_data["auto_clicker_cost"])
	auto_clicker_level = int(save_data["auto_clicker_level"])
	
	restore_passive_income_timer()

	update_ui()
	message_label.text = "Game loaded!"
	
	
func _on_reset_button_pressed() -> void:
	reset_game()

func show_click_message() -> void:
	if clicks_per_click == 1:
		message_label.text = "+" + str(clicks_per_click) + " click!"
	else:
		message_label.text = "+" + str(clicks_per_click) + " clicks!"

func can_afford_upgrade() -> bool:
	return clicks >= upgrade_cost

func can_afford_auto_clicker() -> bool:
	return clicks >= auto_clicker_cost

func buy_upgrade() -> void:
	clicks -= upgrade_cost
	clicks_per_click += CLICKS_PER_CLICK_INCREASE
	upgrade_cost += UPGRADE_COST_INCREASE
	upgrade_modifier += UPGRADE_MODIFIER
	message_label.text = "Upgrade bought!"

func buy_auto_clicker() -> void:
	clicks -= auto_clicker_cost
	passive_clicks_per_tick += PASSIVE_CLICKS_INCREASE
	auto_clicker_cost += AUTO_CLICKER_COST_INCREASE
	auto_clicker_level += 1
	message_label.text = "Auto Clicker bought!"

func _on_passive_income_timer_timeout() -> void:
	# passive-income logic
	earn_passive_clicks()
	update_ui()


func _on_auto_clicker_button_pressed() -> void:	
	if can_afford_auto_clicker():
		buy_auto_clicker()
		start_passive_income_timer()
		update_ui()
