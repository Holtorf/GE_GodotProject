extends Node

export(PackedScene) var mob_scene
var score

var playerPosX
var playerPosY

var startX
var startY

var mobPosX
var mobPosY

var screen_size

var _MapWidth
var _MapHeight
var _CellSize
var _BorderWidth

var _bObstacleMap = []

var _FlowFieldZ = []

func _ready():
	randomize()
	_new_game()
	
	screen_size = get_viewport().get_rect().size
	
	_BorderWidth = 4
	_CellSize = 32
	
	_MapWidth = screen_size.x / _CellSize
	_MapHeight = screen_size.y / _CellSize
	
	_bObstacleMap = [_MapWidth * _MapHeight]
	_FlowFieldZ = [_MapWidth * _MapHeight]
	
	playerPosX = $StartPosition.position.x
	playerPosY = $StartPosition.position.y
	
	startX = 0
	startY = 0
	
	auto 
	
	# x , y, distance
	var listOne = [[],[],[]]
	
	listOne.append = [[playerPosX],[playerPosY],[1]] 



func _game_over():
	$ScoreTimer.stop()
	$MobTime.stop()
	
	#get_tree().call_group("mobs", "queue_free")

func _new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	

func _process(delta: float) -> void:
	playerPosX = $Player.position.x
	playerPosY = $Player.position.y
	
	
	
	for x in _MapWidth:
		for y in _MapHeight:
			if x == 0:
				_FlowFieldZ[x, y] = -1;
			elif y == 0:
				_FlowFieldZ[x, y] = -1;
			elif x == (_MapWidth - 1):
				_FlowFieldZ[x, y] = -1;
			elif y == (_MapHeight - 1):
				_FlowFieldZ[x, y] = -1;
			elif _bObstacleMap[x,y]:
				_FlowFieldZ[x, y] = -1;
			else:
				_FlowFieldZ[x, y] = 0;

#func _calculatePathNew():
	
	



func _on_MobTimer_timeout() -> void:
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation");
	mob_spawn_location.offset = randi()
	
	var mob = mob_scene.instance()
	add_child(mob)
	mob.position = mob_spawn_location.position
	
	var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	


func _on_ScoreTimer_timeout() -> void:
	score += 1
	

func _on_StartTimer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
