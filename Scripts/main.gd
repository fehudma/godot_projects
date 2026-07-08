extends Control

var clicks: int = 0
var clicks_per_click: int = 1

@onready var clicks_label: Label = $VBoxContainer/Label
@onready var click_button: Button = $VBoxContainer/Button

# initialize custom signal and on-click functionality
func _ready() -> void:
	click_button.pressed.connect(_on_click_button_pressed)
	update_clicks_label()

# on-click functionality
func _on_click_button_pressed() -> void:
	print("Button Clicked")
	clicks += clicks_per_click
	update_clicks_label()

# on-click function definition
func update_clicks_label() -> void:
	print("Clicks: ", clicks)
	clicks_label.text = "Clicks: " + str(clicks)
