extends Control
#=======================VARs
var attack: int = 10
var defense: int = 5

#=======================OnReadies
@onready var attack_label: Label = $AttackLabel

#=======================HELPER FUNCTIONs
func update_stats_display() -> void:
	$AttackLabel.text = "Attack: " + str(attack)
	$DefenseLabel.text = "Defense: " + str(defense)

#=======================INIT

func _ready() -> void:
	update_stats_display()





#=======================SIGNALs
func _on_recruit_button_pressed() -> void:
	attack = randi_range(5, 15)
	defense = randi_range(3, 10)
	update_stats_display()
