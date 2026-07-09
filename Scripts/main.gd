#========================================
extends Control
#========================================
var clicks: int = 0
var clicks_per_click: int = 1
var upgrade_cost: int = 3
var upgrade_modifier: int = 1
#========================================
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var click_button: Button = $VBoxContainer/ClickButton
@onready var upgrade_button: Button = $VBoxContainer/UpgradeButton
#========================================
func update_ui() -> void:
	update_stats_label()
	update_upgrade_button()
# on-click function definition
func update_stats_label() -> void:
	print("Clicks: ", clicks)
	#stats_label.text = "Clicks: " + str(clicks)
	stats_label.text = "Clicks: " + str(clicks) + "\nPer Click: " + str(clicks_per_click)
#
func update_upgrade_button() -> void:
	upgrade_button.text = "Upgrade Cost: " + str(upgrade_cost)
	upgrade_button.disabled = clicks < upgrade_cost
#========================================
# initialize custom signal and on-click functionality
func _ready() -> void:
	click_button.pressed.connect(_on_click_button_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	update_ui()

# on-click functionality
func _on_click_button_pressed() -> void:
	print("Click Button Clicked")
	print("Upgrade modif: ",upgrade_modifier)
	clicks += clicks_per_click
	# check grammar for 1 click and multiple clicks
	if clicks_per_click == 1:
		message_label.text = "+" + str(clicks_per_click) + " click!"
	else:
		message_label.text = "+" + str(clicks_per_click) + " clicks!"
	
	update_ui()

# on-upgrade functionality
func _on_upgrade_button_pressed() -> void:
	print("Upgrade Button Clicked")
	if clicks >= upgrade_cost:
		clicks -= upgrade_cost
		clicks_per_click += 1
		upgrade_cost += 2
		update_ui()
		upgrade_modifier = clicks_per_click
		print("Upgrade bought")
		message_label.text = "Upgrade bought!"
		print("Upgrade modif: ",upgrade_modifier)
	else:
		print("can't buy upg")
		message_label.text = "Not enough clicks!"
	
