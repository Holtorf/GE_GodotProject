extends Area2D

var cell_width
var cell_height
var cells_x
var cells_y

export var move_speed = 12

var direction_vector : Vector2 setget, direction_vector_get
func direction_vector_get():
	return direction_vector


func _ready():
	cell_width = GameVariables.cell_width
	cell_height = GameVariables.cell_height
	cells_x = GameVariables.cells_x
	cells_y = GameVariables.cells_y
	hide()
	
	move_speed *= get_parent().game_speed
	
	var mob_position = Vector2(0, cells_y - 1 if (cells_y - 1) % 2 == 0 else cells_y - 2)
	set_position(GameVariables._cell_to_position(mob_position))
	show()
	
	set_process(false)
	
	while (GameVariables.cell_array_sum.empty()):
		yield(get_tree().create_timer(.1), "timeout")
	
	#yield(get_tree().create_timer(2), "timeout")
	set_process(true)


func _process(delta):
	$Line2D.clear_points()
	_find_path(delta)
	


func _find_path(delta):
	var last_pos = GameVariables._position_to_cell(position)
	var new_pos = _find_next_cell(last_pos)
	
	direction_vector = new_pos-last_pos
	
	position = lerp(position, GameVariables._cell_to_position(new_pos), min(delta * move_speed, 1))
	
	$Line2D.add_point(GameVariables._cell_to_position(new_pos) - position)
	
	var iterations_count = 0
	while (last_pos != new_pos && iterations_count < cells_x * cells_y):
		#yield(get_tree().create_timer(0.001), "timeout")
		last_pos = new_pos
		new_pos = _find_next_cell(new_pos)
		$Line2D.add_point(GameVariables._cell_to_position(new_pos) - position)
		iterations_count += 1
	
	#print("path length: ", iterations_count)


func _find_next_cell(current_cell):
	var next_cell = current_cell
	var next_cell_influence = GameVariables.cell_array_sum[current_cell.x][current_cell.y]
	var connections = GameVariables._find_connections(current_cell.x, current_cell.y)
	for cell in connections:
		if (typeof(GameVariables.cell_array_sum[cell[0]][cell[1]]) != TYPE_NIL):
			var influence = GameVariables.cell_array_sum[cell[0]][cell[1]]
			if (influence > next_cell_influence):
				next_cell_influence = influence
				next_cell = cell
	
	return GameVariables._array_to_vector2(next_cell)
