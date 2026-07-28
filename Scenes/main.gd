extends Control

@onready var status_label: Label = $StatusLabel
@onready var action_button: Button = $ActionButton
@onready var score_label: Label = $ScoreLabel
@onready var bite_timer: Timer = $BiteTimer
@onready var catch_timer: Timer = $CatchTimer

const STARTING_SCORE: int = 0

var fish_is_biting := false

enum FishingState {
	READY,
	WAITING_FOR_BITE,
	FISH_BITING
}

var fishing_state: FishingState = FishingState.READY


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

func _on_action_button_pressed() -> void:
	print("Action button pressed")
	action_button.text = "Waiting for a fish..."
	action_button.disabled = true

	var wait_time := randf_range(2.0, 6.0) 
	bite_timer.start(wait_time)


func _on_bite_timer_timeout() -> void:
	fish_is_biting = true
	
	action_button.disabled = false
	status_label.text = "A fish is biting! Raise the hook!"
	action_button.text = "Raise the hook!"
	
	catch_timer.start(2.0)



func _on_catch_timer_timeout() -> void:
	fish_is_biting = false
	
	status_label.text = "The fish escaped!"
	action_button.text = "Drop Hook" 
	action_button.disabled = false
