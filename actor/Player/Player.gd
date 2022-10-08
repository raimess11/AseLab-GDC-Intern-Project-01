extends KinematicBody2D
class_name Player

#sinyal kalo darah berkurang, dan player mati
signal health_changed(health) 
signal player_killed()

var velocity = Vector2.ZERO
var speed = 50
var max_speed = 200
var friction = 30
var stamina = 100

export var max_health = 100

#on ready, set health jadi max health
onready var health = max_health setget _set_health
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var timer = $Timer
onready var sprite_attack = $Sprite2
onready var sprite_walk = $Sprite

var DASH = 50
var dash_direction = -1
var DASH_SPEED = 1.5 
var is_cooldown = false
var state = MOVE
onready var killArea = $Position2D/KillArea/CollisionShape2D

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
			if stamina > 0 :
				velocity.y = DASH * dash_direction * DASH_SPEED
				is_cooldown = true
				timer.start(0)
				staminaa()
			else:
				yield(get_tree().create_timer(3),"timeout")
				stamina = 100
				
		if Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left"):
			if stamina > 0 :
				velocity.x = DASH * dash_direction * DASH_SPEED
				is_cooldown = true
				timer.start(0)
				staminaa()
			else:
				yield(get_tree().create_timer(3),"timeout")
				stamina = 100

		if Input.is_action_pressed("ui_down") && Input.is_action_pressed("ui_left"):
			if stamina > 0:
				velocity.y = DASH * 1/2 * sqrt(2) * DASH_SPEED
				velocity.x = DASH * -1/2 * sqrt(2)* DASH_SPEED
				is_cooldown = true
				timer.start(0)
				staminaa()
			else:
				yield(get_tree().create_timer(3),"timeout")
				stamina = 100
			
		if Input.is_action_pressed("ui_up") && Input.is_action_pressed("ui_right"):
			if stamina > 0:
				velocity.y = DASH * -1/2 * sqrt(2)* DASH_SPEED
				velocity.x = DASH * 1/2 * sqrt(2) * DASH_SPEED
				is_cooldown = true
				timer.start(0)
				staminaa()
			else:
				yield(get_tree().create_timer(3),"timeout")
				stamina = 100
	move_and_collide(velocity)

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	sprite_attack.visible = true
	sprite_walk.visible = false

func attack_finished():
	state = MOVE

#fungsi damage ngurangin darah sebanyak amount
#kalo punya hal lain yang ngurangin darah
#bisa cek pas collide, body yang dicollide punya method damage atau ga
#kalo punya, panggil body.damage(semaunya)
func damage(amount) :
	_set_health(health - amount)

#fungsi kalo player mati. Belum ada apa2, lebih bagus klo udh ada state machine
func kill() :
	pass

#fungsi yang ngubah current health
func _set_health(value) :
	#dupe health untuk cek apakah health setelah damage berubah atau tdk
	var prev_health = health
	#ubah health sebanyak value
	health = clamp(value, 0, max_health)
	#kalo berubah A.K.A health sebelumnya beda dengan current health
	if not (health == prev_health) :
		#emit sinyal health berubah
		emit_signal("health_changed",health)
		#kalo health 0, emit sinyal player mati
		if health == 0 :
			kill()
			emit_signal("player_killed")
	#debug test, making sure health berubah di output
#	print(health)
#PS can add anim iframes or red flash damage later on

func staminaa():
	if stamina > 0:
		stamina -= 30
		print(stamina)







func _on_AttackArea_body_entered(body):
	if body.name == "Enemy":
		body.hit(100)
