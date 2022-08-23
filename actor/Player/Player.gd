extends KinematicBody2D
class_name Player

var velocity = Vector2.ZERO
var speed = 50
var max_speed = 200
var friction = 30

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")


var DASH = 50
var dash_direction = -1
var DASH_SPEED = 1.5 
var is_cooldown = false
var state = MOVE
onready var killArea = $Position2D/KillArea/CollisionShape2D

onready var timer = $Timer
onready var sprite_attack = $Sprite2
onready var sprite_walk = $Sprite

enum{
	MOVE,
	ATTACK,

}


func _ready():
	animationTree.active = true
	killArea.disabled = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		ATTACK:
			attack_state(delta)
			
	


func _on_Timer_timeout():
	is_cooldown = false

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if Input.is_action_just_pressed("attack"):
			state = ATTACK
	
	if input_vector != Vector2.ZERO:
		#animation
		sprite_attack.visible = false
		sprite_walk.visible = true
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Walk/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationState.travel("Walk")
		#thank you newton
		velocity += input_vector * speed * delta
		velocity = velocity.clamped(max_speed * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO,friction*delta)
		
		
		
	if Input.get_action_strength("ui_right") : 
		dash_direction = 1
	elif Input.get_action_strength("ui_left") : 
		dash_direction = -1
	elif Input.get_action_strength("ui_up"):
		dash_direction = -1
	elif Input.get_action_strength("ui_down"):
		dash_direction = 1

	if is_cooldown == false && Input.is_action_just_pressed("Dash") :
		
		if Input.is_action_pressed("ui_down")|| Input.is_action_pressed("ui_up"):
			velocity.y = DASH * dash_direction * DASH_SPEED
			is_cooldown = true
			timer.start(0)
		
		if Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left"):
			velocity.x = DASH * dash_direction * DASH_SPEED
			is_cooldown = true
			timer.start(0)

		if Input.is_action_pressed("ui_down") && Input.is_action_pressed("ui_left"):
			velocity.y = DASH * 1/2 * sqrt(2) * DASH_SPEED
			velocity.x = DASH * -1/2 * sqrt(2)* DASH_SPEED
			is_cooldown = true
			timer.start(0)
		if Input.is_action_pressed("ui_up") && Input.is_action_pressed("ui_right"):
			velocity.y = DASH * -1/2 * sqrt(2)* DASH_SPEED
			velocity.x = DASH * 1/2 * sqrt(2) * DASH_SPEED
			is_cooldown = true
			timer.start(0)
	move_and_collide(velocity)


func attack_state(delta):
	velocity = Vector2.ZERO
	sprite_attack.visible = true
	sprite_walk.visible = false
	animationState.travel("Attack")

func attack_finished():
	state = MOVE
