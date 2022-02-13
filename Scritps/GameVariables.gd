#This class acts as a singleton and can be accessed from the root.
extends Node

var cell_array : Array = []
var cell_influences : Array = []
var cell_array_sum : Array = []

export var cell_width = 20
export var cell_height = 20
var cells_x : int
var cells_y : int

var _negatives_changed : bool = false

#calculate how many cells fit the screen on ready
func _ready():
	cells_x = int(floor(get_viewport().size.x/cell_width))
	cells_y = int(floor(get_viewport().size.y/cell_height))
	
#calculate the position of a cell in world coordinates
func _cell_to_position(cell):
	if (typeof(cell) == TYPE_ARRAY):
		cell = _array_to_vector2(cell)
	return _vector2i(cell * Vector2(cell_width, cell_height) + Vector2(cell_width / 2, cell_height / 2))

#make a vector contain only integers
func _vector2i(vector):
	return Vector2(int(vector.x), int(vector.y))
	
#convert an array to a Vector2
func _array_to_vector2(array):
	if (typeof(array) != TYPE_ARRAY && typeof(array) != TYPE_VECTOR2):
		push_error("var is not Array or Vector2")
	return Vector2(array[0], array[1])
	
#revert world position to cell coordinates
func _position_to_cell(screen_position):
	return _vector2i( (screen_position) / Vector2(cell_width, cell_height) )

#return an array of adjacent cells in Vector2 format
func _find_connections(x, y):
	var connections = []
	
	if (x > 0):
		#append left cell
		connections.append(Vector2(x-1, y))
	if (x < cells_x - 1):
		#append right cell
		connections.append(Vector2(x+1, y))
	if (y > 0):
		#append upper cell
		connections.append(Vector2(x, y-1))
	if (y < cells_y - 1):
		#append lower cell
		connections.append(Vector2(x, y+1))
	return connections
