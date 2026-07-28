extends Control

@onready var status_label: Label = $StatusLabel
@onready var action_button: Button = $ActionButton
@onready var score_label: Label = $ScoreLabel
@onready var bite_timer: Timer = $BiteTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_action_button_pressed() -> void:
	print("Action button pressed")
	action_button.text = "Waiting for a fish..."
	action_button.disabled = true

	var wait_time := randf_range(2.0, 6.0) 
	bite_timer.start(wait_time)


func _on_bite_timer_timeout() -> void:
	action_button.disabled = false
	status_label.text = "A fish is biting! Raise the hook!"
	action_button.text = "Raise the hook!"



func _on_catch_timer_timeout() -> void:
	pass # Replace with function body.
