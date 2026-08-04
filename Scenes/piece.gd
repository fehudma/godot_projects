extends Node2D

class_name Piece

@onready var letter_label: Label = $LetterLabel

var letter: String = "A"


func _ready() -> void:
	set_letter(letter)


func set_letter(new_letter: String) -> void:
	letter = new_letter
	letter_label.text = letter
