extends Node2D

class_name Piece

@onready var letter_label: Label = $LetterLabel

#==========================VARS
var letter: String = "A"
var grid_position: Vector2i = Vector2i.ZERO

#==========================HELPERS
#
func set_grid_position(new_grid_position: Vector2i) -> void:
	grid_position = new_grid_position

#
func setup(new_letter: String, new_grid_position: Vector2i) -> void:
	set_letter(new_letter)
	set_grid_position(new_grid_position)

#
func play_remove_animation() -> void:
	var tween := create_tween()

	tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ZERO,
		0.15
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		0.15
	)

	await tween.finished
	queue_free()
#==========================INIT
func _ready() -> void:
	set_letter(letter)

func set_letter(new_letter: String) -> void:
	letter = new_letter
	letter_label.text = letter

func set_selected(is_selected: bool) -> void:
	if is_selected:
		letter_label.modulate = Color.YELLOW
	else:
		letter_label.modulate = Color.WHITE


func _on_area_2d_mouse_entered() -> void:
	if not letter_label.modulate == Color.YELLOW:
		letter_label.modulate = Color.LIGHT_GRAY


func _on_area_2d_mouse_exited() -> void:
	if not letter_label.modulate == Color.YELLOW:
		letter_label.modulate = Color.WHITE
