extends Node2D

#==========================CONST
const COLUMNS: int = 8
const ROWS: int = 8
const CELL_SIZE:int = 64

#
const PIECE_SCENE: PackedScene = preload("res://scenes/piece.tscn")

#==========================HELPERS
func grid_to_pixel(column: int, row: int) -> Vector2:
	return Vector2(
		column * CELL_SIZE + CELL_SIZE / 2.0,
		row * CELL_SIZE + CELL_SIZE / 2.0
	)

#==========================
#“Where should the center of cell (column, row) be?”
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


#
func pixel_to_grid(pixel_position: Vector2) -> Vector2i:
	return Vector2i(
		floori(pixel_position.x / CELL_SIZE),
		floori(pixel_position.y / CELL_SIZE)
	)

#
func is_inside_board(grid_position: Vector2i) -> bool:
	return (
		grid_position.x >= 0
		and grid_position.x < COLUMNS
		and grid_position.y >= 0
		and grid_position.y < ROWS
	)

#==========================INIT
func _ready() -> void:
	var piece: Piece = PIECE_SCENE.instantiate()
	add_child(piece)

	var target_cell := Vector2i(2, 3)

	piece.set_grid_position(target_cell)
	piece.position = grid_to_pixel(target_cell.x, target_cell.y)
	piece.set_letter("Y")

	print(piece.grid_position)
