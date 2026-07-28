extends Control

@onready var status_label: Label = $StatusLabel
@onready var action_button: Button = $ActionButton
@onready var score_label: Label = $ScoreLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_action_button_pressed() -> void:
	print("Action button pressed")
	action_button.text = "..."
	#TODO Temporarily disable the button after the hook is dropped.
	# action_button.disabled = true
