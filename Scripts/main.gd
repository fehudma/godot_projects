extends Control
#===================CONSTs
const UPGRADE_COST_INCREASE = 1
const CLICKS_START = 0
const CLICKS_EARNED_START = 1
const UPGRADE_LEVEL_START = 1
const UPGRADE_COST_START = 5
const STARTING_PASSIVE_CLICKS_PER_TICK = 0
#===================Vars
var clicks: int = 0
var clicks_earned: int = 1
var upgrade_level: int = 1
var upgrade_cost: int = 5
var passive_clicks_per_tick: int = STARTING_PASSIVE_CLICKS_PER_TICK
#===================Node References
@onready var label_title: Label = $VBoxContainer/LabelTitle
@onready var label_status: Label = $VBoxContainer/LabelStatus
@onready var label_message: Label = $VBoxContainer/LabelMessage
@onready var button_click: Button = $VBoxContainer/ButtonClick
@onready var button_upgrade: Button = $VBoxContainer/ButtonUpgrade
@onready var button_restart: Button = $VBoxContainer/ButtonRestart
#===================Helpers
func update_ui():
	status_update()
	upgrade_button_text()
#===================Functions
func status_update():
	#update label_status.text
	label_status.text = "Clicks: " + str(clicks) + " " + "\nClicks Power: " + str(clicks_earned) + " "+ "\nUpgrade Level: "+ str(upgrade_level)

func upgrade_button_text():
	button_upgrade.text = "Upgrade cost: " + str(upgrade_cost)
	#update button_upgrade.text
	if clicks >= upgrade_cost:
		button_upgrade.disabled = false
	else:
		button_upgrade.disabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui()

#===================Game start
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_click_pressed() -> void:
	clicks += clicks_earned
	update_ui()



func _on_button_upgrade_pressed() -> void:
	if clicks >= upgrade_cost:
		
		clicks -= upgrade_cost
		clicks_earned += 1
		upgrade_level += 1
		upgrade_cost = upgrade_cost + UPGRADE_COST_INCREASE
		label_message.text = "Upgrade bought!"
	else:
		label_message.text = "Unaffordable"
	update_ui()

func _on_timer_timeout() -> void:
	print("passive_clicks_per_tick")
	passive_clicks_per_tick = 1
	clicks += passive_clicks_per_tick
	update_ui()

func _on_button_restart_pressed() -> void:
	clicks = CLICKS_START
	clicks_earned = CLICKS_EARNED_START
	upgrade_level = UPGRADE_LEVEL_START
	upgrade_cost = UPGRADE_COST_START 
	label_message.text = "Reset!"
	update_ui()
