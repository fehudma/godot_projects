extends Control
#============================EXPORTS
@export var fish_caught_sounds: Array[AudioStream] = []

#============================ONREADYs
@onready var points_label: Label = $VBoxContainer/PointsLabel
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var action_button: Button = $VBoxContainer/ActionButton
@onready var test_button: Button = $VBoxContainer/TestButton
@onready var bite_timer: Timer = $BiteTimer
@onready var catch_timer: Timer = $CatchTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2
@onready var hook_drop_sound: AudioStreamPlayer = $HookDropSound
@onready var fish_bite_state_sound: AudioStreamPlayer = $FishBiteStateSound
@onready var fish_caught_state_sound: AudioStreamPlayer = $FishCaughtStateSound
@onready var session_timer: Timer = $SessionTimer
@onready var session_time_label: Label = $SessionTimeLabel
@onready var equipment_container: VBoxContainer = $EquipmentContainer
@onready var rod_label: Label = $EquipmentContainer/RodLabel
@onready var bait_label: Label = $EquipmentContainer/BaitLabel
@onready var hook_label: Label = $EquipmentContainer/HookLabel
@onready var switch_rod_button: Button = $EquipmentContainer/SwitchRodButton

#============================CONSTs
const STARTING_SCORE: int = 0
const BASE_CATCH_TIME: float = 2.0
#============================VARs
#States
enum FishingState {
	READY,
	WAITING_FOR_BITE,
	FISH_BITING
}

#Starting State
var fishing_state: FishingState = FishingState.READY

#List of all possible fishes as an Array. An array stores multiple values in order. Here, each value is a fish dictionary.
var fish_list: Array[Dictionary] = [
	{
		"name": "Raw Brilliant Smallfish",
		"points": 1,
		"weight": 60
	},
	{
		"name": "Raw Longjaw Mud Snapper",
		"points": 2,
		"weight": 30
	},
	{
		"name": "Raw Slitherskin Mackerel",
		"points": 5,
		"weight": 10
	}
]

var last_caught_fish: Dictionary = {}

var equipped_rod: Dictionary
var equipped_bait: Dictionary
var equipped_hook: Dictionary

#Vars Rods
var basic_rod: Dictionary = {
	"name": "Basic Rod",
	"catch_time_bonus": 0.0
}

var sturdy_rod: Dictionary = {
	"name": "Sturdy Rod",
	"catch_time_bonus": 1.0
}

var reinforced_rod: Dictionary = {
	"name": "Reinforced Rod",
	"catch_time_bonus": 2.0
}


#Vars Baits
var basic_bait: Dictionary = {
	"name": "Basic Bait",
	"wait_time_reduction": 0.0
}

var test_bait: Dictionary = {
	"name": "Test Bait",
	"wait_time_reduction": 1.0
}

#Vars Hooks
var basic_hook: Dictionary = {
	"name": "Basic Hook",
	"rare_fish_bonus": 0.0
}

var test_hook: Dictionary = {
	"name": "Test Hook",
	"rare_fish_bonus": 0.1
}


var owned_rods: Array[Dictionary] = []
var selected_rod_index: int = 0
var owned_baits: Array[Dictionary] = []
var selected_bait_index: int = 0
var owned_hooks: Array[Dictionary] = []
var selected_hook_index: int = 0

#============================HELPERS
func choose_random_fish() -> Dictionary:
	var total_weight: int = 0

	for fish: Dictionary in fish_list:
		total_weight += fish["weight"]

	var roll: int = randi_range(1, total_weight)
	var current_weight: int = 0

	for fish: Dictionary in fish_list:
		current_weight += fish["weight"]

		if roll <= current_weight:
			return fish

	return {}

var total_points: int = 0

#tween func for sound fade, instead of harsh stop
func fade_out_fish_bite_sound() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fish_bite_state_sound, "volume_db", -40.0, 0.9)

	await tween.finished

	fish_bite_state_sound.stop()
	fish_bite_state_sound.volume_db = 0.0

#Update equipment labels from variables
func update_equipment_labels() -> void:
	rod_label.text = (
	"Rod: "
	+ str(equipped_rod["name"])
	+ " (+"
	+ str(equipped_rod["catch_time_bonus"])
	+ "s)"
	)
	bait_label.text = "Bait: " + str(equipped_bait["name"])
	hook_label.text = "Hook: " + str(equipped_hook["name"])

#
func equip_rod(rod: Dictionary) -> void:
	equipped_rod = rod
	update_equipment_labels()

#
func equip_bait(bait: Dictionary) -> void:
	equipped_bait = bait
	update_equipment_labels()

#
func equip_hook(hook: Dictionary) -> void:
	equipped_hook = hook
	update_equipment_labels()

#
func initialize_equipment() -> void:
	equipped_rod = owned_rods[selected_rod_index]
	equipped_bait = owned_baits[selected_bait_index]
	equipped_hook = owned_hooks[selected_hook_index]
	update_equipment_labels()


#
func get_rod_catch_time_bonus() -> float:
	return float(equipped_rod["catch_time_bonus"])

func get_total_catch_time() -> float:
	return BASE_CATCH_TIME + get_rod_catch_time_bonus()
#============================INIT

func _ready() -> void:
	print("Game Started")
	
	randomize()
	
	owned_rods.append(basic_rod)
	owned_rods.append(sturdy_rod)
	owned_rods.append(reinforced_rod)
	owned_baits.append(basic_bait)
	owned_baits.append(test_bait)
	owned_hooks.append(basic_hook)
	owned_hooks.append(test_hook)
	
	initialize_equipment()
	
	update_equipment_labels()
	
	session_timer.start()

func _process(delta: float) -> void:
	var time_left: float = session_timer.time_left
	#%.1f means:// f: format a floating-point number // .1: show one digit after the decimal point // 59.9999 becomes 60.0 // 59.94 becomes 59.9 // 8.26 becomes 8.3
	session_time_label.text = "Time: %.1f" % time_left
	

func _on_action_button_pressed() -> void:
	if fishing_state == FishingState.FISH_BITING:
		catch_timer.stop()
		animation_player.stop()
		animation_player_2.stop()
		###fish_bite_state_sound.stop()
		fade_out_fish_bite_sound()
		animation_player.play("hook_up")
		
		fishing_state = FishingState.READY
		
		last_caught_fish = choose_random_fish()
		total_points = total_points + int(last_caught_fish["points"])
		
		print("User caught a " + last_caught_fish["name"] 
		+ "," + " reward points: " + str(last_caught_fish["points"]))
		print("total points: " + str(total_points))
		points_label.text = "Points: " + str(total_points)
		status_label.text = ("You caught a " + last_caught_fish["name"] + "!" 
		+ " +" + str(last_caught_fish["points"]) + " points")
		action_button.text = "Drop Hook"
		
		var random_sound: AudioStream = fish_caught_sounds.pick_random()
		fish_caught_state_sound.stream = random_sound
		fish_caught_state_sound.play()
		return

	if fishing_state == FishingState.WAITING_FOR_BITE:
		bite_timer.stop()
		animation_player.play("hook_up")
		#TODO sound bug possible when hook up before fish bites
		fishing_state = FishingState.READY
		status_label.text = "Too early! The fish was scared away."
		action_button.text = "Drop Hook"
		return
	
	fishing_state = FishingState.WAITING_FOR_BITE
	switch_rod_button.disabled = true
	action_button.text = "Waiting for a fish..."
	animation_player.play("hook_down")
	hook_drop_sound.play()
	
	var wait_time := randf_range(0.5, 2.0) 
	bite_timer.start(wait_time)

#============================SIGNALS
func _on_bite_timer_timeout() -> void:
	fishing_state = FishingState.FISH_BITING
	print("Biting timer started")
	animation_player.play("fish_bite")
	animation_player_2.play("hook_sides")
	fish_bite_state_sound.play()
	
	status_label.text = "A fish is biting! Raise the hook!"
	action_button.text = "Raise the hook!"
	
	catch_timer.start(get_total_catch_time())


func _on_catch_timer_timeout() -> void:
	animation_player.stop()
	###fish_bite_state_sound.stop()
	fade_out_fish_bite_sound()
	print("Escape timer ended")
	animation_player_2.stop()
	animation_player.play("hook_up")
	fishing_state = FishingState.READY
	
	status_label.text = "The fish escaped!"
	action_button.text = "Drop Hook" 


func _on_session_timer_timeout() -> void:
	catch_timer.stop()
	bite_timer.stop()
	animation_player.stop()
	animation_player_2.stop()
	fade_out_fish_bite_sound()
	fishing_state = FishingState.READY
	action_button.disabled = true
	status_label.text = "The session is over"

func _on_switch_rod_button_pressed() -> void:
	selected_rod_index += 1
	
	if selected_rod_index >= owned_rods.size():
		selected_rod_index = 0
	
	equip_rod(owned_rods[selected_rod_index])

#selected_bait_index
func _on_switch_bait_button_pressed() -> void:
	selected_bait_index += 1
	
	if selected_bait_index >= owned_baits.size():
		selected_bait_index = 0
	
	equip_bait(owned_baits[selected_bait_index])


func _on_switch_hook_button_pressed() -> void:
	selected_hook_index += 1
	
	if selected_hook_index >= owned_hooks.size():
		selected_hook_index = 0
	
	equip_hook(owned_hooks[selected_hook_index])

#============================TEST BUTTON
func _on_test_button_pressed() -> void:
	#print("Session timer started: ", session_timer.time_left)
	print("***")
	print(get_rod_catch_time_bonus())
