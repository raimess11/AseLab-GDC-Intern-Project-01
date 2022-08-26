extends KinematicBody2D
class_name Player

#sinyal kalo darah berkurang, dan player mati
signal health_changed(health) 
signal player_killed()

var velocity = Vector2.ZERO
var speed = 50
var max_speed = 200
var friction = 30

export var max_health = 100

#on ready, set health jadi max health
onready var health = max_health setget _set_health
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var timer = $Timer

func _ready():
	pass
var DASH = 50
var dash_direction = -1
var DASH_SPEED = 1.5 
var is_cooldown = false

func _physics_process(delta):
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if Input.get_action_strength("ui_right") : 
		dash_direction = 1
	elif Input.get_action_strength("ui_left") : 
		dash_direction = -1
	elif Input.get_action_strength("ui_up"):
		dash_direction = -1
	elif Input.get_action_strength("ui_down"):
		dash_direction = 1
	
	
	if input_vector != Vector2.ZERO:
		#animation
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Walk/blend_position", input_vector)
		animationState.travel("Walk")
		#thank you newton
		velocity += input_vector * speed * delta
		velocity = velocity.clamped(max_speed * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO,friction*delta)
		
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

func _on_Timer_timeout():
	is_cooldown = false

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
	print(health)
#PS can add anim iframes or red flash damage later on
