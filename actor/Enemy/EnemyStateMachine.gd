extends KinematicBody2D


enum STATE {
	IDLE,
	WANDER,
	CHASE
}

#Atur kecepatan enemy
var run_speed = 50
var state_enemy
#atur akselerasi
var akselerasi = 300
# Atur toleransi jarak dengan player
var tolerance = 4.0
#Untuk menggerakkan objek
var velocity = Vector2.ZERO
#Asumsi belum ketemu player
var player = null

onready var start_position = global_position
onready var target_position = global_position

func update_target_position():
	var target_vector = Vector2(rand_range(-32, 32), rand_range(-32, 32))
	target_position = start_position + target_vector

func is_at_target_position(): 
	# Akan berhenti saat target +/- toleransi
	return (target_position - global_position).length() < tolerance
	
func accelerate_to_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	accelerate(acceleration_vector)

func accelerate(acceleration_vector):
	velocity += acceleration_vector
	velocity = velocity.clamped(run_speed)

#Aksi IDLE
func _ready():
	state_enemy = STATE.IDLE # Replace with function body.

#Aksi Chase
func _on_Area2D_body_entered(body): # Replace with function body.
	if body.name == "player":
		player = body
		state_enemy = STATE.CHASE

#Aksi WANDER
func _on_Area2D_body_exited(body): # Replace with function body.
	if body.name == "player":
		player = null
		state_enemy = STATE.WANDER

func _physics_process(delta):
	#Untuk Enemy
	match STATE: 
		#Lakukan aksi IDLE
		STATE.IDLE:
			pass
		#Lakukan aksi WANDER
		STATE.CHASE:
			 if player:
					velocity = position.direction_to(player.position) * run_speed
					velocity = move_and_slide(velocity)
		#Lakukan aksi Chase
		STATE.WANDER:
			accelerate_to_point(target_position, akselerasi * delta)
			if is_at_target_position():
				state_enemy = STATE.IDLE
