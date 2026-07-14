#========================================
extends Control
#========================================
const STARTING_CLICKS: int = 0
const STARTING_CLICKS_PER_CLICK: int = 1
const STARTING_UPGRADE_COST: int = 3
const STARTING_UPGRADE_LEVEL: int = 0
const UPGRADE_COST_INCREASE: int = 2
const CLICKS_PER_CLICK_INCREASE: int = 1
const STARTING_TIMEOUT_COUNT: int = 0
const AUTO_CLICKER_COST_START: int = 5
const STARTING_PASSIVE_CLICKS_PER_TICK: int = 0
const AUTO_CLICKER_COST_INCREASE: int = 5
const PASSIVE_CLICKS_INCREASE: int = 1
const STARTING_AUTO_CLICKER_LEVEL: int = 0
#========================================
var clicks: int = STARTING_CLICKS
var clicks_per_click: int = STARTING_CLICKS_PER_CLICK
var upgrade_cost: int = STARTING_UPGRADE_COST
var upgrade_modifier: int = STARTING_UPGRADE_LEVEL
var timeout_count: int = STARTING_TIMEOUT_COUNT
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
	print("Clicks: ", clicks)
	#stats_label.text = "Clicks: " + str(clicks)
	stats_label.text = "Clicks: " + str(clicks) + "\nPer Click: " + str(clicks_per_click) + "\nPer Timer: " + str(passive_clicks_per_tick) + "\nAuto Clicker Level: " + str(auto_clicker_level)
#
func update_upgrade_button() -> void:
	upgrade_button.text = "Click Upgrade Cost: " + str(upgrade_cost)
	upgrade_button.disabled = not can_afford_upgrade()
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
#========================================
# initialize custom signal and on-click functionality
func _ready() -> void:
	click_button.pressed.connect(_on_click_button_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	update_ui()

# on-click functionality
func _on_click_button_pressed() -> void:
	print("Click Button Clicked")
	print("Upgrade modif: ",upgrade_modifier)
	clicks += clicks_per_click
	# check grammar for 1 click and multiple clicks
	show_click_message()
	update_ui()

# on-upgrade functionality
func _on_upgrade_button_pressed() -> void:
	print("Upgrade Button Clicked")
	if can_afford_upgrade():
		buy_upgrade()
		update_ui()
	else:
		print("can't buy upg")
		message_label.text = "Not enough clicks!"

func _on_reset_button_pressed() -> void:
	clicks = STARTING_CLICKS
	clicks_per_click = STARTING_CLICKS_PER_CLICK
	upgrade_cost= STARTING_UPGRADE_COST
	upgrade_modifier= STARTING_UPGRADE_LEVEL
	timeout_count = STARTING_TIMEOUT_COUNT
	passive_clicks_per_tick = STARTING_PASSIVE_CLICKS_PER_TICK
	auto_clicker_cost= AUTO_CLICKER_COST_START
	auto_clicker_level = STARTING_AUTO_CLICKER_LEVEL
	stop_passive_income_timer()
	print("Timer tick reset! Total counts: ", timeout_count)
	message_label.text = "Game Reset."
	update_ui()

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
	upgrade_modifier = clicks_per_click
	print("Upgrade bought")
	message_label.text = "Upgrade bought!"
	print("Upgrade modif: ",upgrade_modifier)

func buy_auto_clicker() -> void:
	clicks -= auto_clicker_cost
	passive_clicks_per_tick += PASSIVE_CLICKS_INCREASE
	auto_clicker_cost += AUTO_CLICKER_COST_INCREASE
	auto_clicker_level += 1
	message_label.text = "Auto Clicker bought!"

func _on_passive_income_timer_timeout() -> void:
	# Tracks the number of timeouts
	timeout_count += 1
	print("Timer tick! Total counts: ", timeout_count)
	# other timer functionality
	clicks += passive_clicks_per_tick
	update_ui()


func _on_auto_clicker_button_pressed() -> void:
	print("Autoclicker Button Pressed")
	
	if can_afford_auto_clicker():
		buy_auto_clicker()
		start_passive_income_timer()
		update_ui()
