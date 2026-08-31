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


#==========================onreadies
@onready var breaker_button: Button = $"../BreakerButton"
@onready var score_label: Label = $"../ScoreLabel"


#==========================VARS
var grid: Array[Array] = []

var selected_cell: Vector2i = Vector2i(-1, -1)
var second_cell: Vector2i = Vector2i(-1, -1)

var input_locked: bool = false

var breaker_active: bool = false

var score: int = 0
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

#
#Detect a horizontal match at one cell
func has_horizontal_match_at(grid_position: Vector2i) -> bool:
	var piece: Piece = grid[grid_position.x][grid_position.y]

	if piece == null:
		return false

	var matching_count: int = 1

	var column: int = grid_position.x - 1

	while column >= 0:
		var left_piece: Piece = grid[column][grid_position.y]

		if left_piece == null or left_piece.letter != piece.letter:
			break

		matching_count += 1
		column -= 1

	column = grid_position.x + 1

	while column < COLUMNS:
		var right_piece: Piece = grid[column][grid_position.y]

		if right_piece == null or right_piece.letter != piece.letter:
			break

		matching_count += 1
		column += 1

	return matching_count >= 3


#
#Detect a vertical match at one cell
func has_vertical_match_at(grid_position: Vector2i) -> bool:
	var piece: Piece = grid[grid_position.x][grid_position.y]

	if piece == null:
		return false

	var matching_count: int = 1

	var row: int = grid_position.y - 1

	while row >= 0:
		var above_piece: Piece = grid[grid_position.x][row]

		if above_piece == null or above_piece.letter != piece.letter:
			break

		matching_count += 1
		row -= 1

	row = grid_position.y + 1

	while row < ROWS:
		var below_piece: Piece = grid[grid_position.x][row]

		if below_piece == null or below_piece.letter != piece.letter:
			break

		matching_count += 1
		row += 1

	return matching_count >= 3

#
#Combine horizontal and vertical checks
func has_match_at(grid_position: Vector2i) -> bool:
	return (
		has_horizontal_match_at(grid_position)
		or has_vertical_match_at(grid_position)
	)

#
#Collect the horizontal matched pieces
func get_horizontal_match_at(grid_position: Vector2i) -> Array[Piece]:
	var center_piece: Piece = grid[grid_position.x][grid_position.y]

	if center_piece == null:
		return []
	
	var matched_pieces: Array[Piece] = [center_piece]

	var column: int = grid_position.x - 1

	while column >= 0:
		var left_piece: Piece = grid[column][grid_position.y]

		if left_piece == null or left_piece.letter != center_piece.letter:
			break

		matched_pieces.append(left_piece)
		column -= 1

	column = grid_position.x + 1

	while column < COLUMNS:
		var right_piece: Piece = grid[column][grid_position.y]

		if right_piece == null or right_piece.letter != center_piece.letter:
			break

		matched_pieces.append(right_piece)
		column += 1

	if matched_pieces.size() < 3:
		matched_pieces.clear()

	return matched_pieces


#
#Collect the vertical matched pieces
func get_vertical_match_at(grid_position: Vector2i) -> Array[Piece]:
	var center_piece: Piece = grid[grid_position.x][grid_position.y]

	if center_piece == null:
		return []
	var matched_pieces: Array[Piece] = [center_piece]

	var row: int = grid_position.y - 1

	while row >= 0:
		var above_piece: Piece = grid[grid_position.x][row]

		if above_piece == null or above_piece.letter != center_piece.letter:
			break
		matched_pieces.append(above_piece)
		row -= 1

	row = grid_position.y + 1

	while row < ROWS:
		var below_piece: Piece = grid[grid_position.x][row]

		if below_piece == null or below_piece.letter != center_piece.letter:
			break

		matched_pieces.append(below_piece)
		row += 1

	if matched_pieces.size() < 3:
		matched_pieces.clear()

	return matched_pieces


#
#Combine horizontal and vertical matched
func get_matches_at(grid_position: Vector2i) -> Array[Piece]:
	var matched_pieces: Array[Piece] = []

	var horizontal_match := get_horizontal_match_at(grid_position)
	var vertical_match := get_vertical_match_at(grid_position)

	for piece: Piece in horizontal_match:
		if not matched_pieces.has(piece):
			matched_pieces.append(piece)

	for piece: Piece in vertical_match:
		if not matched_pieces.has(piece):
			matched_pieces.append(piece)

	return matched_pieces

#
#
func get_matches_from_swap(
	first_cell: Vector2i,
	second_cell: Vector2i
) -> Array[Piece]:
	var matched_pieces: Array[Piece] = []

	for piece: Piece in get_matches_at(first_cell):
		if not matched_pieces.has(piece):
			matched_pieces.append(piece)

	for piece: Piece in get_matches_at(second_cell):
		if not matched_pieces.has(piece):
			matched_pieces.append(piece)

	return matched_pieces


#
#Remove matched pieces
func remove_matched_pieces(matched_pieces: Array[Piece]) -> void:
	score += matched_pieces.size()
	update_score_display()
	
	for piece: Piece in matched_pieces:
		var cell: Vector2i = piece.grid_position

		grid[cell.x][cell.y] = null
		piece.queue_free()


#
#Collapse one column after removals
func collapse_column(column: int) -> void:
	for row: int in range(ROWS - 1, -1, -1):
		if grid[column][row] == null:
			for search_row: int in range(row - 1, -1, -1):
				var piece_above: Piece = grid[column][search_row]

				if piece_above != null:
					grid[column][row] = piece_above
					grid[column][search_row] = null

					piece_above.set_grid_position(Vector2i(column, row))
					piece_above.position = grid_to_pixel(column, row)

					break


#
#Collapse every column
func collapse_all_columns() -> void:
	for column: int in range(COLUMNS):
		collapse_column(column)


#
#create new pieces in any null cells left after collapsing
func refill_board() -> void:
	for column: int in range(COLUMNS):
		for row: int in range(ROWS):
			if grid[column][row] == null:
				create_piece(Vector2i(column, row))


#
#Find all matches currently on the board
func get_all_matches() -> Array[Piece]:
	var matched_pieces: Array[Piece] = []

	for column: int in range(COLUMNS):
		for row: int in range(ROWS):
			var cell_matches: Array[Piece] = get_matches_at(
				Vector2i(column, row)
			)

			for piece: Piece in cell_matches:
				if not matched_pieces.has(piece):
					matched_pieces.append(piece)

	return matched_pieces


#
#resolve matches (repeatedly if need be)
func resolve_cascades() -> void:
	var new_matches: Array[Piece] = get_all_matches()

	while not new_matches.is_empty():
		remove_matched_pieces(new_matches)
		collapse_all_columns()
		refill_board()

		new_matches = get_all_matches()


#
#Check whether any valid move exists
func swap_would_create_match(
	first_cell: Vector2i,
	second_cell: Vector2i
) -> bool:
	swap_pieces_in_grid(first_cell, second_cell)

	var creates_match: bool = (
		has_match_at(first_cell)
		or has_match_at(second_cell)
	)

	swap_pieces_in_grid(second_cell, first_cell)

	return creates_match


#
#Scan the board for at least one valid move
func has_possible_move() -> bool:
	for column: int in range(COLUMNS):
		for row: int in range(ROWS):
			var current_cell := Vector2i(column, row)

			var right_cell := Vector2i(column + 1, row)
			if is_inside_board(right_cell):
				if swap_would_create_match(current_cell, right_cell):
					return true

			var below_cell := Vector2i(column, row + 1)
			if is_inside_board(below_cell):
				if swap_would_create_match(current_cell, below_cell):
					return true

	return false


#
#do a simple reshuffle (if dead board, for example)
func reshuffle_board() -> void:
	var board_is_valid: bool = false

	while not board_is_valid:
		for column: int in range(COLUMNS):
			for row: int in range(ROWS):
				var piece: Piece = grid[column][row]
				piece.set_letter(get_random_letter())

		var has_matches: bool = not get_all_matches().is_empty()
		var has_move: bool = has_possible_move()

		board_is_valid = not has_matches and has_move

#Find one possible move
func find_possible_move() -> Array[Vector2i]:
	for column: int in range(COLUMNS):
		for row: int in range(ROWS):
			var current_cell := Vector2i(column, row)

			var right_cell := Vector2i(column + 1, row)
			if is_inside_board(right_cell):
				if swap_would_create_match(current_cell, right_cell):
					return [current_cell, right_cell]

			var below_cell := Vector2i(column, row + 1)
			if is_inside_board(below_cell):
				if swap_would_create_match(current_cell, below_cell):
					return [current_cell, below_cell]

	return []


#Update the visible score
func update_score_display() -> void:
	score_label.text = "Score: " + str(score)


#==========================OTHER FUNCTIONS
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
	if input_locked:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var local_mouse_position := to_local(event.position)
			var clicked_cell := pixel_to_grid(local_mouse_position)

			if is_inside_board(clicked_cell):
				var clicked_piece: Piece = grid[clicked_cell.x][clicked_cell.y]

				if clicked_piece == null:
					return
				
				if breaker_active:
					input_locked = true

					var matched_pieces: Array[Piece] = [clicked_piece]
					remove_matched_pieces(matched_pieces)

					collapse_all_columns()
					refill_board()
					resolve_cascades()

					if not has_possible_move():
						reshuffle_board()

					breaker_active = false
					breaker_button.text = "Breaker"
					input_locked = false
					return
				
				if selected_cell == Vector2i(-1, -1):
					selected_cell = clicked_cell
					var selected_piece: Piece = grid[selected_cell.x][selected_cell.y]
					selected_piece.set_selected(true)
				else:
					second_cell = clicked_cell

					var first_piece: Piece = grid[selected_cell.x][selected_cell.y]

					if second_cell == selected_cell:
						first_piece.set_selected(false)
						selected_cell = Vector2i(-1, -1)

					elif are_cells_adjacent(selected_cell, second_cell):
						swap_pieces_in_grid(selected_cell, second_cell)

						var first_has_match: bool = has_match_at(second_cell)
						var second_has_match: bool = has_match_at(selected_cell)
						var swap_created_match: bool = first_has_match or second_has_match

						if not swap_created_match:
							swap_pieces_in_grid(second_cell, selected_cell)
						else:
							var matched_pieces: Array[Piece] = get_matches_from_swap(
								second_cell,
								selected_cell
							)
							
							input_locked = true
							
							remove_matched_pieces(matched_pieces)
							collapse_all_columns()
							refill_board()
							resolve_cascades()
							
							if not has_possible_move():
								print("Dead board detected. Re-shuffling...")
								reshuffle_board()

							input_locked = false


							for piece: Piece in get_matches_at(second_cell):
								if not matched_pieces.has(piece):
									matched_pieces.append(piece)

							for piece: Piece in get_matches_at(selected_cell):
								if not matched_pieces.has(piece):
									matched_pieces.append(piece)

						
						first_piece.set_selected(false)
						selected_cell = Vector2i(-1, -1)

					else:
						first_piece.set_selected(false)

						selected_cell = second_cell
						var new_selected_piece: Piece = grid[selected_cell.x][selected_cell.y]
						new_selected_piece.set_selected(true)

					second_cell = Vector2i(-1, -1)


func _on_hint_button_pressed() -> void:
	print("Hint requested")
	if input_locked:
		return
	
	var selected_piece: Piece = grid[selected_cell.x][selected_cell.y]

	if selected_piece != null:
		selected_piece.set_selected(false)

	selected_cell = Vector2i(-1, -1)
	
	var possible_move: Array[Vector2i] = find_possible_move()

	if possible_move.is_empty():
		return

	var first_piece: Piece = grid[possible_move[0].x][possible_move[0].y]
	var second_piece: Piece = grid[possible_move[1].x][possible_move[1].y]

	input_locked = true

	first_piece.set_selected(true)
	second_piece.set_selected(true)

	await get_tree().create_timer(1.0).timeout

	first_piece.set_selected(false)
	second_piece.set_selected(false)

	input_locked = false


func _on_breaker_button_pressed() -> void:
	print("Breaker toggled")
	
	if input_locked:
		return

	if selected_cell != Vector2i(-1, -1):
		var selected_piece: Piece = grid[selected_cell.x][selected_cell.y]

		if selected_piece != null:
			selected_piece.set_selected(false)

		selected_cell = Vector2i(-1, -1)

	breaker_active = not breaker_active
	
	if breaker_active:
		breaker_button.text = "Breaker: ON"
	else:
		breaker_button.text = "Breaker"


func _on_test_button_pressed() -> void:
	#collapse_column(0)
	#reshuffle_board()
	print("Test requested")
