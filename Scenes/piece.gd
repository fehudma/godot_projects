extends Node2D

class_name Piece

#==========================CONSTs
const BLUE_ORB: Texture2D = preload("res://assets/pieces/blue_orb.png")
const ORANGE_DIAMOND: Texture2D = preload("res://assets/pieces/orange_diamond.png")
const PURPLE_STAR: Texture2D = preload("res://assets/pieces/purple_star.png")
const PINK_HEART: Texture2D = preload("res://assets/pieces/pink_heart.png")
const GREEN_LEAF: Texture2D = preload("res://assets/pieces/green_leaf.png")


const PIECE_BRIGHTNESS := {
	"A": 1.15, # Blue orb
	"B": 1.35, # Orange diamond
	"C": 0.80, # Purple star
	"X": 1.00, # Pink-red heart
	"Y": 1.10, # Green leaf
}
#==========================ONREADYs
@onready var piece_sprite: Sprite2D = $PieceSprite

#==========================VARS
var letter: String = "A"
var grid_position: Vector2i = Vector2i.ZERO
var is_selected: bool = false
var breaker_targetable: bool = false

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

func set_breaker_targetable(is_targetable: bool) -> void:
	breaker_targetable = is_targetable

#==========================INIT
func _ready() -> void:
	set_letter(letter)

func set_letter(new_letter: String) -> void:
	letter = new_letter

	match letter:
		"A":
			piece_sprite.texture = BLUE_ORB
		"B":
			piece_sprite.texture = ORANGE_DIAMOND
		"C":
			piece_sprite.texture = PURPLE_STAR
		"X":
			piece_sprite.texture = PINK_HEART
		"Y":
			piece_sprite.texture = GREEN_LEAF

func set_selected(selected: bool) -> void:
	is_selected = selected

	if is_selected:
		piece_sprite.modulate = Color.YELLOW
	else:
		piece_sprite.modulate = Color.WHITE


func _on_area_2d_mouse_entered() -> void:
	if is_selected:
		return

	if breaker_targetable:
		piece_sprite.modulate = Color.ORANGE
	else:
		piece_sprite.modulate = Color.LIGHT_GRAY


func _on_area_2d_mouse_exited() -> void:
	if not is_selected:
		piece_sprite.modulate = Color.WHITE
