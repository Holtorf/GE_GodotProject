extends Node

var score

var playerPosition
var velocity

export var cell_width = 20
export var cell_height = 20
var cell_array = []
var cell_array_color = []
var cell_array_positive = []
var cell_array_negative = []
var cells_x
var cells_y
var player
export var game_speed : float = 1

func _ready():
	randomize()
	cells_x = int(floor(get_viewport().size.x/cell_width))
	cells_y = int(floor(get_viewport().size.y/cell_height))
	
	_create_new_grid()
	_new_game()

func _process(delta: float) -> void:
	playerPosition = $Player.position

func _create_new_grid():
	_generate_grid()
	
	cell_array_positive = cell_array.duplicate(true)
	cell_array_positive[_get_random_cell().x][_get_random_cell().y] = 1
	
	cell_array_negative = cell_array.duplicate(true)
	#cell_array_negative[_get_random_cell().x][_get_random_cell().y] = -1
	
	_color_cells()
	
	yield(_propagate_grid(), "completed")
	
	mob_position = _get_random_cell()
	$Mob.set_position(_cell_to_position(mob_position))
	#$Mob.show()
	
	yield(_find_path(mob_position), "completed")

func _find_path(start_pos):
	var path = [start_pos]
	var new_pos = _find_next_cell(start_pos)
	var iterations_count = 0
	while (path[-1] != new_pos):
		yield(get_tree().create_timer(0.1), "timeout")
		path.append(new_pos)
		new_pos = _find_next_cell(new_pos)
		iterations_count += 1
		if (path.size() > cells_x * cells_y): break
	
	print("iterations: ", iterations_count)

func _find_next_cell(current_cell):
	var next_cell = current_cell
	var next_cell_influence = cell_array[current_cell.x][current_cell.y]
	var connections = _find_connections(current_cell.x, current_cell.y)
	for cell in connections:
		var influence = cell_array[cell[0]][cell[1]]
		if (influence > next_cell_influence):
			next_cell_influence = influence
			next_cell = cell
	$Line2D.add_point(_cell_to_position(current_cell))
	$Line2D.add_point(_cell_to_position(next_cell))
	
	return _array_to_vector2(next_cell)

func _generate_grid():
	var cell_scene = preload("res://src/Cell.tscn")
	for x in range(cells_x):
		cell_array.append([])
		cell_array_color.append([])
		
		for y in range(cells_y):
			var cell = cell_scene.instance()
			cell.set_position(Vector2(x*cell_width,y*cell_height))
			cell_array[x].append(0)
			cell_array_color[x].append(cell.get_node("ColorRect"))
			cell_array_color[x][y].color = Color( 0, 0, 0, 0 )
			cell_array_color[x][y].set_size(Vector2(cell_width,cell_height))
			add_child(cell)

func _propagate_grid():
	var propagation_count = 0
	for c in cells_x:
		yield(get_tree().create_timer(0.1), "timeout")
		var positive_changed = _propagate_positive()
		propagation_count += 1
		for x in range(cell_array.size()):
			for y in range(cell_array[x].size()):
				cell_array[x][y] = cell_array_positive[x][y] + cell_array_negative[x][y]
		_color_cells()
	




func _game_over():
	$ScoreTimer.stop()
	$MobTime.stop()
	

func _new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	


func _on_ScoreTimer_timeout() -> void:
	score += 1
	

func _on_StartTimer_timeout() -> void:

	$ScoreTimer.start()
