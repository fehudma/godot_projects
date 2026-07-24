#========================================
extends Control
#========================================
const STARTING_CLICKS: int = 0
const STARTING_CLICKS_PER_CLICK: int = 1
const STARTING_UPGRADE_COST: int = 3
const STARTING_UPGRADE_LEVEL: int = 0
const MANUAL_UPGRADE_LEVEL: int = 1
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
	"manual_upgrade_level",
	"passive_clicks_per_tick",
	"auto_clicker_cost",
	"auto_clicker_level"
]
#========================================
var clicks: int = STARTING_CLICKS
var clicks_per_click: int = STARTING_CLICKS_PER_CLICK
var upgrade_cost: int = STARTING_UPGRADE_COST
var manual_upgrade_level: int = STARTING_UPGRADE_LEVEL
var passive_clicks_per_tick: int = STARTING_PASSIVE_CLICKS_PER_TICK
var auto_clicker_cost: int = AUTO_CLICKER_COST_START
var auto_clicker_level: int = STARTING_AUTO_CLICKER_LEVEL
var click_button_tween: Tween
var upgrade_button_tween: Tween
var auto_clicker_button_tween: Tween
var save_button_tween: Tween
var load_button_tween: Tween
var reset_button_tween: Tween
#========================================
@onready var stats_label: Label = $VBoxContainer/TabContainer/Worker1/StatsLabel
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var click_button: Button = $VBoxContainer/TabContainer/Worker1/ClickButton
@onready var upgrade_button: Button = $VBoxContainer/TabContainer/Worker1/UpgradeButton
@onready var auto_clicker_button: Button = $VBoxContainer/TabContainer/Worker1/AutoClickerButton
@onready var save_button: Button = $VBoxContainer/SaveButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var reset_button: Button = $VBoxContainer/ResetButton
@onready var passive_income_timer: Timer = $PassiveIncomeTimer
#========================================
func update_ui() -> void:
	update_stats_label()
	update_upgrade_button()
	update_buy_auto_clicker_button()

#========================================HELPERs functions
#
func show_message(message: String) -> void:
	message_label.text = message
# 
func update_stats_label() -> void:
	stats_label.text = "Clicks: " + format_number(clicks) + "\nClick Power: " + format_number(clicks_per_click) + "\nAuto Click Power: " + format_number(passive_clicks_per_tick) + "\nAuto Clicker Level: " + format_number(auto_clicker_level)
#
func update_upgrade_button() -> void:
	upgrade_button.text = "Click Upgrade Cost: " + format_number(upgrade_cost)
	upgrade_button.disabled = not can_afford_upgrade()
#
func is_auto_clicker_unlocked() -> bool:
	if manual_upgrade_level >= AUTO_CLICKER_UNLOCK_LEVEL:
		return true
	else:
		return false

#
func update_buy_auto_clicker_button() -> void:
	if not is_auto_clicker_unlocked(): #same as "if is_auto_clicker_unlocked() == false:"
		auto_clicker_button.text = "Auto Clicker Unlock at Click Upgrade Level: " + str(AUTO_CLICKER_UNLOCK_LEVEL)
		auto_clicker_button.disabled = true
	else:
		auto_clicker_button.text = "Auto Clicker Lv. " + format_number(auto_clicker_level) + " — Cost: " + format_number(auto_clicker_cost)
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
	save_data["manual_upgrade_level"] = manual_upgrade_level
	save_data["passive_clicks_per_tick"] = passive_clicks_per_tick
	save_data["auto_clicker_cost"] = auto_clicker_cost
	save_data["auto_clicker_level"] = auto_clicker_level
	return save_data

func reset_game_values() -> void:
	clicks = STARTING_CLICKS
	clicks_per_click = STARTING_CLICKS_PER_CLICK
	upgrade_cost= STARTING_UPGRADE_COST
	manual_upgrade_level= STARTING_UPGRADE_LEVEL
	passive_clicks_per_tick = STARTING_PASSIVE_CLICKS_PER_TICK
	auto_clicker_cost= AUTO_CLICKER_COST_START
	auto_clicker_level = STARTING_AUTO_CLICKER_LEVEL

func reset_game() -> void:
	reset_game_values()
	stop_passive_income_timer()
	show_message("Game reset.")
	update_ui()

func format_number(value: int) -> String:
	if value < 1000:
		return str(value)

	if value < 1_000_000:
		var shortened_value: float = value / 1000.0
		var rounded_value: float = round(shortened_value * 10.0) / 10.0
		
		if rounded_value >= 1000.0:
			return "1M"

		if rounded_value == int(rounded_value):
			return str(int(rounded_value)) + "K"

		return str(rounded_value) + "K"
		
	if value < 1_000_000_000:
		var shortened_value: float = value / 1_000_000.0
		var rounded_value: float = round(shortened_value * 10.0) / 10.0
		
		if rounded_value >= 1000.0:
			return "1B"
		
		if rounded_value == int(rounded_value):
			return str(int(rounded_value)) + "M"
		
		return str(rounded_value) + "M"
	
	if value < 1_000_000_000_000:
		var shortened_value: float = value / 1_000_000_000.0
		var rounded_value: float = round(shortened_value * 10.0) / 10.0

		if rounded_value == int(rounded_value):
			return str(int(rounded_value)) + "B"

		return str(rounded_value) + "B"

	return str(value)
#
func play_click_button_feedback() -> void:
	if click_button_tween:
		click_button_tween.kill()

	click_button.pivot_offset = click_button.size / 2.0
	click_button.scale = Vector2.ONE

	click_button_tween = create_tween()
	click_button_tween.tween_property(
		click_button,
		"scale",
		Vector2(0.9, 0.9),
		0.05
	)
	click_button_tween.tween_property(
		click_button,
		"scale",
		Vector2.ONE,
		0.08
	)

func play_button_feedback(button: Button, current_tween: Tween) -> Tween:
	if current_tween:
		current_tween.kill()

	button.pivot_offset = button.size / 2.0
	button.scale = Vector2.ONE

	var new_tween: Tween = create_tween()
	new_tween.tween_property(
		button,
		"scale",
		Vector2(0.9, 0.9),
		0.05
	)
	new_tween.tween_property(
		button,
		"scale",
		Vector2.ONE,
		0.08
	)

	return new_tween
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
	show_click_message()
	play_click_button_feedback()
	update_ui()

# on-upgrade functionality
func _on_upgrade_button_pressed() -> void:
	if can_afford_upgrade():
		upgrade_button_tween = play_button_feedback(
			upgrade_button,
			upgrade_button_tween
		)
		
		var was_unlocked: bool = is_auto_clicker_unlocked()
		buy_upgrade()
		
		if not was_unlocked and is_auto_clicker_unlocked():
			show_message("Manual upgrade bought and auto clicker unlocked.")
		
		update_ui()

func _on_save_button_pressed() -> void:
	save_button_tween = play_button_feedback(
	save_button,
	save_button_tween
	)
	
	var save_data: Dictionary = collect_save_data()
	var json_text: String = JSON.stringify(save_data)
	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)

	if save_file == null:
		show_message("Could not save game.")
		return

	save_file.store_string(json_text)
	show_message("Game saved.")
	
	

func _on_load_button_pressed() -> void:
	load_button_tween = play_button_feedback(
	load_button,
	load_button_tween
	)
	
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		show_message("No Savefile exists.")
		return
	
	var save_file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	
	if save_file == null:
		show_message("Could not load game.")
		return

	var json_text: String = save_file.get_as_text()
	
	var loaded_data: Variant = JSON.parse_string(json_text)
	
	if typeof(loaded_data) != TYPE_DICTIONARY:
		show_message("Save file is invalid.")
		return
	
	var save_data: Dictionary = loaded_data
	#check (validate) dictionary for presence of keys
	if not save_data.has_all(REQUIRED_SAVE_KEYS):
		show_message("Save file is missing data.")
		return
	#check (validate) dictionary for correct data type inside of keys
	for key: String in REQUIRED_SAVE_KEYS:
		var value: Variant = save_data[key]
		
		if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
			show_message("Save file contains invalid values.")
			return
	
	clicks = int(save_data["clicks"])
	clicks_per_click = int(save_data["clicks_per_click"])
	upgrade_cost = int(save_data["upgrade_cost"])
	manual_upgrade_level = int(save_data["manual_upgrade_level"])
	passive_clicks_per_tick = int(save_data["passive_clicks_per_tick"])
	auto_clicker_cost = int(save_data["auto_clicker_cost"])
	auto_clicker_level = int(save_data["auto_clicker_level"])
	
	restore_passive_income_timer()

	update_ui()
	show_message("Game loaded.")
	
	
func _on_reset_button_pressed() -> void:
	reset_button_tween = play_button_feedback(
	reset_button,
	reset_button_tween
	)
	
	reset_game()

func show_click_message() -> void:
	if clicks_per_click == 1:
		message_label.text = "+" + format_number(clicks_per_click) + " click!"
	else:
		message_label.text = "+" + format_number(clicks_per_click) + " clicks!"

func can_afford_upgrade() -> bool:
	return clicks >= upgrade_cost

func can_afford_auto_clicker() -> bool:
	return clicks >= auto_clicker_cost

func buy_upgrade() -> void:
	clicks -= upgrade_cost
	clicks_per_click += CLICKS_PER_CLICK_INCREASE
	upgrade_cost += UPGRADE_COST_INCREASE
	manual_upgrade_level += MANUAL_UPGRADE_LEVEL
	show_message("Manual upgrade bought.")

func buy_auto_clicker() -> void:
	clicks -= auto_clicker_cost
	passive_clicks_per_tick += PASSIVE_CLICKS_INCREASE
	auto_clicker_cost += AUTO_CLICKER_COST_INCREASE
	auto_clicker_level += 1
	show_message("Auto clicker bought.")

func _on_passive_income_timer_timeout() -> void:
	# passive-income logic
	earn_passive_clicks()
	update_ui()


func _on_auto_clicker_button_pressed() -> void:
	if not is_auto_clicker_unlocked():
		return

	if can_afford_auto_clicker():
		auto_clicker_button_tween = play_button_feedback(
			auto_clicker_button,
			auto_clicker_button_tween
		)
		
		buy_auto_clicker()
		start_passive_income_timer()
		update_ui()
