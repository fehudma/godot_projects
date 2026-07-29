extends Control

@onready var status_label: Label = $StatusLabel
@onready var action_button: Button = $ActionButton
@onready var score_label: Label = $ScoreLabel
@onready var bite_timer: Timer = $BiteTimer
@onready var catch_timer: Timer = $CatchTimer

const STARTING_SCORE: int = 0

#States
enum FishingState {
	READY,
	WAITING_FOR_BITE,
	FISH_BITING
}

#Starting State
var fishing_state: FishingState = FishingState.READY

#List of all possible fishes
var fish: Dictionary = {
	"name": "Raw Brilliant Smallfish",
	"points": 1,
	"weight": 60
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	print(fish["name"])
	print(fish["points"])
	print(fish["weight"])

func _on_action_button_pressed() -> void:
	if fishing_state == FishingState.FISH_BITING:
		catch_timer.stop()
		fishing_state = FishingState.READY
		
		status_label.text = "You caught a fish!"
		action_button.text = "Drop Hook"
		return
	
	if fishing_state == FishingState.WAITING_FOR_BITE:		
		bite_timer.stop()
		fishing_state = FishingState.READY
		status_label.text = "Too early! The fish was scared away."
		action_button.text = "Drop Hook"
		return
	
	fishing_state = FishingState.WAITING_FOR_BITE
	action_button.text = "Waiting for a fish..."
	
	var wait_time := randf_range(2.0, 6.0) 
	bite_timer.start(wait_time)


func _on_bite_timer_timeout() -> void:
	print("Biting timer started")
	fishing_state = FishingState.FISH_BITING
	
	action_button.disabled = false
	status_label.text = "A fish is biting! Raise the hook!"
	action_button.text = "Raise the hook!"
	
	catch_timer.start(2.0)



func _on_catch_timer_timeout() -> void:
	print("Escape timer ended")
	fishing_state = FishingState.READY
	
	status_label.text = "The fish escaped!"
	action_button.text = "Drop Hook" 
	action_button.disabled = false
