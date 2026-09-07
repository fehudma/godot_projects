@tool
extends Polygon2D

const COLUMNS: int = 7
const ROWS: int = 7
const CELL_WIDTH: int = 128
const CELL_HEIGHT: int = 128

func _ready() -> void:
	visible = Engine.is_editor_hint()
	update_preview()

func update_preview() -> void:
	var board_width: float = COLUMNS * CELL_WIDTH
	var board_height: float = ROWS * CELL_HEIGHT

	polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(board_width, 0),
		Vector2(board_width, board_height),
		Vector2(0, board_height)
	])
