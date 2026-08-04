extends Node2D

class_name Piece

@onready var letter_label: Label = $LetterLabel

#==========================VARS
var letter: String = "A"
var grid_position: Vector2i = Vector2i.ZERO

#==========================HELPERS
func set_grid_position(new_grid_position: Vector2i) -> void:
	grid_position = new_grid_position

#==========================INIT
func _ready() -> void:
	set_letter(letter)


func set_letter(new_letter: String) -> void:
	letter = new_letter
	letter_label.text = letter
