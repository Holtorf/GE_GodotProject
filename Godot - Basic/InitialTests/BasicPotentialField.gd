extends Node

export(PackedScene) var mob_scene

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

var score
var velocity
var mob_position

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	cells_x = int(floor(get_viewport().size.x/cell_width))
	cells_y = int(floor(get_viewport().size.y/cell_height))
	
	$Mob.hide()
	_create_new_grid()
	_new_game()

func _new_game():
	score = 0
	$StartTimer.start()

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
	$Mob.show()
	
	yield(_find_path(mob_position), "completed")
	#yield(get_tree().create_timer(1), "timeout")
	#get_tree().reload_current_scene()

func _process(delta: float) -> void:
	if mob_position != null:
		yield(_find_path(mob_position), "completed")
		GameVariables.cell_influences.append([$Player.playerPosition, Vector2(cells_x - 1,0), 1])
		

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
	var cell_scene = preload("res://ScenesAndScripts/Cell/Cell.tscn")
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
		#var negative_changed = _propagate_negative()
		propagation_count += 1
		#if !positive_changed && !negative_changed: break
		
		for x in range(cell_array.size()):
			for y in range(cell_array[x].size()):
				cell_array[x][y] = cell_array_positive[x][y] + cell_array_negative[x][y]
		_color_cells()
	
	print("propagations: ", propagation_count)


func _propagate_positive():
	var influence_changed = false
	
	for x in range(cell_array_positive.size()):
		for y in range(cell_array_positive[x].size()):
			
			var max_influence = cell_array_positive[x][y]
			var connections = _find_connections(x, y)
			
			for cell in connections:
				var influence = cell_array_positive[cell[0]][cell[1]] * exp(-0.15)
				max_influence = max(influence, max_influence)
			
			influence_changed = true if cell_array_positive[x][y] != max_influence else influence_changed
			
			cell_array_positive[x][y] = max_influence
	
	return influence_changed


#func _propagate_negative():
	#var influence_changed = false
	
	#for x in range(cell_array_negative.size()):
		#for y in range(cell_array_negative[x].size()):
			
			#var min_influence = cell_array_negative[x][y]
			#var connections = _find_connections(x, y)
			
			#for cell in connections:
			#	var influence = cell_array_negative[cell[0]][cell[1]] * exp(-0.6)
			#	min_influence = min(influence, min_influence)
			#
			#influence_changed = true if cell_array_negative[x][y] != min_influence else influence_changed
			#
			#cell_array_negative[x][y] = min_influence
	
	#return influence_changed


func _find_connections(x, y):
	var connections = []
	if (x > 0):
		connections.append([x-1, y])
	if (x < cells_x - 1):
		connections.append([x+1, y])
	if (y > 0):
		connections.append([x, y-1])
	if (y < cells_y - 1):
		connections.append([x, y+1])
	return connections

func _color_cells():
	for x in range(cell_array_color.size()):
		for y in range(cell_array_color[x].size()):
			cell_array_color[x][y].color = Color(0.0,0.0,0.2,0.8)

func _get_random_pos():
	return Vector2(randi() % cells_x * cell_width + cell_width / 2,
		randi() % cells_y * cell_height + cell_height / 2)

func _get_random_cell():
	return Vector2(randi() % cells_x, randi() % cells_y)

func _cell_to_position(cell):
	if (typeof(cell) == TYPE_ARRAY):
		cell = _array_to_vector2(cell)
	return cell * Vector2(cell_width, cell_height) + Vector2(cell_width / 2, cell_height / 2)
	
func _array_to_vector2(array):
	if (typeof(array) != TYPE_ARRAY && typeof(array) != TYPE_VECTOR2):
		push_error("var is not Array or Vector2")
	return Vector2(array[0], array[1])



func _on_ScoreTimer_timeout() -> void:
	score += 1

func _on_StartTimer_timeout() -> void:
	#$MobTimer.start()
	$ScoreTimer.start()
