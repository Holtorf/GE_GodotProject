extends Node

export(PackedScene) var mob_scene
var score

var playerPosX
var playerPosY

var startX
var startY

var mobs = []

var velocity


func _ready():
	randomize()
	_new_game()



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
	if mobs.size() > 0:
		_calculateGoal()

func _calculateGoal():
	var distance : int = 0
	var angle : int = 0
	var degrees : int = 0
	var relativeX : int = 0
	var relativeY : int = 0
	var angleDifference : int = 0
	var directionX = $Player.position.x + PI / 2.00
	var directionY =  $Player.position.y + PI / 2.00
	
	for i in mobs.size():
		distance = sqrt(pow((playerPosX - mobs[i].position.x),2) + pow((playerPosY - mobs[i].position.y),2))
		
		print("Distnace: ", distance)
		
		relativeX = playerPosX - mobs[i].position.x
		relativeY = playerPosY - mobs[i].position.y
		
		
		
		angle = atan2(-(relativeY), relativeX)
		degrees = angle*(180 / PI)
		degrees = -(degrees)
		print("Angle: ", angle)
		
		if degrees < 0:
			degrees = (degrees + 360) % 360
		
		print("Degrees: ",degrees)
		#angleDifference = mobs[i].rotation - degrees;
		
		#if angleDifference > 0:
		#	if angleDifference < 180:
		#		mobs[i].rotation = -10
		#	else:
		#		mobs[i].rotation = 10
		#else:
		#	if angleDifference > -180:
		#		mobs[i].rotation = 10
		#	else:
		#		mobs[i].rotation = -10
		if distance >= 10:
			mobs[i].linear_velocity = velocity.rotated(degrees)
		
		
	

func _on_MobTimer_timeout() -> void:
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation");
	mob_spawn_location.offset = randi()
	
	var mob = mob_scene.instance()
	
	add_child(mob)
	mob.position = mob_spawn_location.position
	
	velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	mobs.append(mob)
	print(mobs.size())


func _on_ScoreTimer_timeout() -> void:
	score += 1
	

func _on_StartTimer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
