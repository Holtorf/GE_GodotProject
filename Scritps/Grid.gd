extends Node

export var positive_influence = 0.1
export var negative_influence = 3

var cell_array = []
var cell_array_color = []
var cell_array_positive = []
var cell_array_negative = []

var cell_width
var cell_height
var cells_x
var cells_y
export var min_ladders = 1
export var max_ladders = 3

export var show_propagation_values : bool = false

func _ready():
	cell_array = 
	cell_array = GameVariables.cell_array
	
	#These variables are stored in the singleton. 
	#Hence, in case of a reload those variables have been already assigned and 
	#so they need to be cleared. 
	GameVariables.cell_array.clear()
	GameVariables.cell_influences.clear()
	GameVariables.cell_array_sum.clear()
	
	_generate_new_grid()

#update the negative propagation on new frame if neccesary
func _process(_delta):
	if (GameVariables._negatives_changed):
		_update_negative_propagation()

#set up the starter grid
func _generate_new_grid():
	_generate_grid()
	GameVariables.cell_influences.append(["Goal", Vector2(cells_x - 1,0), 1])
	_propagate_grid()

#generate a grid pattern
func _generate_grid():
	cell_width = GameVariables.cell_width
	cell_height = Grid.cell_height
	cells_x = GameVariables.cells_x
	cells_y = GameVariables.cells_y
	
	var cell_scene = preload("res://src/Cell.tscn")
	var ladders = _generate_ladders_array()
	
	for x in range(cells_x):
		cell_array.append([])
		cell_array_color.append([])
		for y in range(cells_y):
			var cell = cell_scene.instance()
			cell.set_position(Vector2(x*cell_width,y*cell_height))
			
			if (!ladders[y].has(x) && ((y % 4 == 3 && x != cells_x - 1) || (y % 4 == 1 && x != 0))):
				cell_array[x].append(null)
			else:
				cell_array[x].append(0)
			
			cell_array_color[x].append(cell.get_node("ColorRect"))
			cell_array_color[x][y].color = Color( 0, 0, 0, 0 )
			cell_array_color[x][y].set_size(Vector2(cell_width,cell_height))
			add_child(cell)
	GameVariables.cell_array = cell_array
	_color_terrain()
	
func _make_floor_sprites_visible(sprite):
	sprite.visible = true
	sprite.scale = Vector2(cell_width / 32,cell_height / 32)

func _make_ladder_sprites_visible(sprite):
	#var sprite : Sprite = cell_array_color[x][y].get_parent().get_node("Sprite")
	sprite.visible = true
	sprite.scale = Vector2(cell_width / 32,cell_height / 32)
	sprite.texture = load("res://Textures/ladder.png")


#color floor cells
func _color_terrain():
	for x in range(cells_x):
		for y in range(cells_y):
			#if (show_propagation_values):
			#	var intensity = -.6 if typeof(GameVariables.cell_array[x][y]) == TYPE_NIL else 0
			#	cell_array_color[x][y].color = Color(1,1,1,intensity)
			if (typeof(GameVariables.cell_array[x][y]) == TYPE_NIL):
				var sprite : Sprite = cell_array_color[x][y].get_parent().get_node("Sprite")
				_make_floor_sprites_visible(sprite)
			#print(y)
			if ((y+1) % 2 == 0 && typeof(GameVariables.cell_array[x][y]) != TYPE_NIL):
				for i in range(3):
					var ladder_part = y-1+i
					if(ladder_part <= cells_y-1):
						var sprite : Sprite = cell_array_color[x][ladder_part].get_parent().get_node("Sprite")
						_make_ladder_sprites_visible(sprite)


#color other cells
func _color_cells():
	for x in range(cells_x):
		for y in range(cells_y):
			var intensity = GameVariables.cell_array_sum[x][y] if typeof(GameVariables.cell_array_sum[x][y]) != TYPE_NIL else -.6
			cell_array_color[x][y].color = Color(1,1,1,intensity)


func _generate_ladders_array():
	var int_array = []
	
	for y in range(cells_y):
		int_array.append([])
		var amount = randi() % (max_ladders - min_ladders) + min_ladders
		for a in amount:
			int_array[y].append(randi() % (cells_x - 4) + 2)
	return int_array


func _propagate_grid():
	cell_array_positive = GameVariables.cell_array.duplicate(true)
	cell_array_negative = GameVariables.cell_array.duplicate(true)
	var cell_array_sum = []
	
	for cell in GameVariables.cell_influences:
		if (cell[2] >= 0):
			cell_array_positive[cell[1].x][cell[1].y] = cell[2]
		else:
			cell_array_negative[cell[1].x][cell[1].y] = cell[2]
	
	for c in cells_x * cells_y:
		var positive_changed = _propagate(true)
		var negative_changed = _propagate(false)
		
		for x in range(cells_x):
			cell_array_sum.append([])
			for y in range(cells_y):
				cell_array_sum[x].append(null)
				if (typeof(cell_array_positive[x][y]) != TYPE_NIL && typeof(cell_array_negative[x][y]) != TYPE_NIL):
					cell_array_sum[x][y] = cell_array_positive[x][y] + cell_array_negative[x][y]
		GameVariables.cell_array_sum = cell_array_sum
		if (show_propagation_values): _color_cells()
		if !positive_changed && !negative_changed: break


func _update_negative_propagation():
	cell_array_negative = GameVariables.cell_array.duplicate(true)
	var cell_array_sum = cell_array_positive.duplicate(true)
	
	for cell in GameVariables.cell_influences:
		if (cell[2] < 0):
			cell_array_negative[cell[1].x][cell[1].y] = cell[2]
	
	for c in cells_x * cells_y:
		var negative_changed = _propagate(false)
		
		for x in range(cells_x):
			for y in range(cells_y):
				if (typeof(cell_array[x][y]) != TYPE_NIL):
					cell_array_sum[x][y] += cell_array_negative[x][y]
		
		GameVariables.cell_array_sum = cell_array_sum
		if (show_propagation_values): _color_cells()
		if !negative_changed: break
	
	GameVariables.cell_array_sum = cell_array_sum
	GameVariables._negatives_changed = false


func _propagate(positive):
	var influence_changed = false
	
	for x in range(cells_x):
		for y in range(cells_y):
			
			var start_influence = cell_array_positive[x][y] if positive else cell_array_negative[x][y]
			
			if (typeof(cell_array[x][y]) != TYPE_NIL):
				var max_influence = start_influence
				var connections = GameVariables._find_connections(x, y)
				
				for cell in connections:
					if (typeof(cell_array[cell[0]][cell[1]]) != TYPE_NIL):
						var influence = cell_array_positive[cell[0]][cell[1]] if positive else cell_array_negative[cell[0]][cell[1]]
						influence *= exp(-positive_influence) if positive else exp(-negative_influence)
						max_influence = max(influence, max_influence) if positive else min(influence, max_influence)
				
				influence_changed = true if start_influence != max_influence else influence_changed
				
				if positive:
					cell_array_positive[x][y] = max_influence
				else:
					cell_array_negative[x][y] = max_influence
		
	return influence_changed
