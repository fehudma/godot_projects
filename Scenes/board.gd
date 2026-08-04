extends Node2D

#==========================CONST
const COLUMNS: int = 8
const ROWS: int = 8
const CELL_SIZE:int = 64

#
const PIECE_SCENE: PackedScene = preload("res://scenes/piece.tscn")


#
const PIECE_LETTERS: Array[String] = [
	"A",
	"B",
	"C",
	"X",
	"Y"
]


#==========================VARS
var grid: Array[Array] = []

var selected_cell: Vector2i = Vector2i(-1, -1)
var second_cell: Vector2i = Vector2i(-1, -1)

#==========================HELPERS
#
func grid_to_pixel(column: int, row: int) -> Vector2:
	return Vector2(
		column * CELL_SIZE + CELL_SIZE / 2.0,
		row * CELL_SIZE + CELL_SIZE / 2.0
	)

#
func get_random_letter() -> String:
	return PIECE_LETTERS.pick_random()

#
func create_piece(grid_position: Vector2i) -> Piece:
	var piece: Piece = PIECE_SCENE.instantiate()
	add_child(piece)

	piece.setup(get_valid_starting_letter(grid_position), grid_position)
	piece.position = grid_to_pixel(grid_position.x, grid_position.y)

	grid[grid_position.x][grid_position.y] = piece

	return piece

#
func create_empty_grid() -> void:
	grid.clear()

	for column: int in range(COLUMNS):
		var new_column: Array[Piece] = []

		for row: int in range(ROWS):
			new_column.append(null)

		grid.append(new_column)

#
#check the two cells to the left and the two cells above
func would_create_starting_match(
	grid_position: Vector2i,
	letter: String
) -> bool:
	var column := grid_position.x
	var row := grid_position.y

	if column >= 2:
		var left_piece: Piece = grid[column - 1][row]
		var far_left_piece: Piece = grid[column - 2][row]

		if left_piece.letter == letter and far_left_piece.letter == letter:
			return true

	if row >= 2:
		var above_piece: Piece = grid[column][row - 1]
		var far_above_piece: Piece = grid[column][row - 2]

		if above_piece.letter == letter and far_above_piece.letter == letter:
			return true

	return false


#
#Choose a letter that avoids starting matches
func get_valid_starting_letter(grid_position: Vector2i) -> String:
	var letter := get_random_letter()

	while would_create_starting_match(grid_position, letter):
		letter = get_random_letter()

	return letter

#check if the pieces are adjacent
func are_cells_adjacent(first_cell: Vector2i, second_cell: Vector2i) -> bool:
	var difference := second_cell - first_cell
	return abs(difference.x) + abs(difference.y) == 1

#
#Swap the two pieces in the grid array
func swap_pieces_in_grid(first_cell: Vector2i, second_cell: Vector2i) -> void:
	var first_piece: Piece = grid[first_cell.x][first_cell.y]
	var second_piece: Piece = grid[second_cell.x][second_cell.y]

	grid[first_cell.x][first_cell.y] = second_piece
	grid[second_cell.x][second_cell.y] = first_piece

	first_piece.set_grid_position(second_cell)
	second_piece.set_grid_position(first_cell)

	first_piece.position = grid_to_pixel(second_cell.x, second_cell.y)
	second_piece.position = grid_to_pixel(first_cell.x, first_cell.y)
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
	create_empty_grid()

	for column: int in range(COLUMNS):
		for row: int in range(ROWS):
			create_piece(Vector2i(column, row))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var local_mouse_position := to_local(event.position)
			var clicked_cell := pixel_to_grid(local_mouse_position)

			if is_inside_board(clicked_cell):
				if selected_cell == Vector2i(-1, -1):
					selected_cell = clicked_cell
					var selected_piece: Piece = grid[selected_cell.x][selected_cell.y]
					selected_piece.set_selected(true)
				else:
					second_cell = clicked_cell
					var cells_are_adjacent: bool = are_cells_adjacent(
						selected_cell,
						second_cell
					)

					if cells_are_adjacent:
						swap_pieces_in_grid(selected_cell, second_cell)

					var first_piece: Piece = grid[selected_cell.x][selected_cell.y]
					first_piece.set_selected(false)

					selected_cell = Vector2i(-1, -1)
					second_cell = Vector2i(-1, -1)
			
			
