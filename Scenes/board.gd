extends Node2D

#==========================CONST
const COLUMNS: int = 8
const ROWS: int = 8
const CELL_SIZE:int = 64

#==========================HELPERS
func _draw() -> void:
	for column: int in range(COLUMNS):
		for row: int in range(ROWS):
			var cell_position := Vector2(
				column * CELL_SIZE,
				row * CELL_SIZE
			)

			var cell_rectangle := Rect2(
				cell_position,
				Vector2(CELL_SIZE, CELL_SIZE)
			)

			draw_rect(cell_rectangle, Color.DARK_GRAY, false, 2.0)
