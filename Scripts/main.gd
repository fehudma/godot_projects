extends Control

var clicks: int = 0
var clicks_per_click: int = 1
var upgrade_cost: int = 3
var upgrade_modifier: int = 1

@onready var clicks_label: Label = $VBoxContainer/Label
@onready var click_button: Button = $VBoxContainer/ClickButton
@onready var upgrade_button: Button = $VBoxContainer/UpgradeButton

# initialize custom signal and on-click functionality
func _ready() -> void:
	click_button.pressed.connect(_on_click_button_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	update_clicks_label()
	

# on-click functionality
func _on_click_button_pressed() -> void:
	print("Click Button Clicked")
	print("Upgrade modif: ",upgrade_modifier)
	clicks += clicks_per_click
	update_clicks_label()

# on-upgrade functionality
func _on_upgrade_button_pressed() -> void:
	print("Upgrade Button Clicked")
	if clicks >= upgrade_cost:
		clicks -= upgrade_cost
		update_clicks_label()
		upgrade_modifier += clicks_per_click
		print("Upgrade bought")
		print("Upgrade modif: ",upgrade_modifier)
	else:
		print("can't buy upg")
	

# on-click function definition
func update_clicks_label() -> void:
	print("Clicks: ", clicks)
	clicks_label.text = "Clicks: " + str(clicks)
