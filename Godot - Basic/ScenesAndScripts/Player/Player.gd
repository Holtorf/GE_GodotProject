extends Area2D

signal hit
signal haveMoved

export var speed = 400
var screen_size
var playerPosition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	#hide ()

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("right"):
		velocity.x += 1
		emit_signal("haveMoved")	
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		emit_signal("haveMoved")	
	if Input.is_action_pressed("down"):
		velocity.y += 1
		emit_signal("haveMoved")	
	if Input.is_action_pressed("up"):
		velocity.y -= 1	
		emit_signal("haveMoved")	
	
	playerPosition = GameVariables._position_to_cell(position)
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if velocity.x != 0:
		$AnimatedSprite.animation ="walk"
		$AnimatedSprite.flip_v = false
		
		$AnimatedSprite.flip_h = velocity.x < 0
	
	elif velocity.y !=0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0


func _on_Player_body_entered(body: Node) -> void:
	#hide()
	emit_signal("hit")
	
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
