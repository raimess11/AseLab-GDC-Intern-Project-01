extends KinematicBody2D

#Variabel untuk kondisi state enemy
var state_enemy

#Memanggil script dari KecepatanMusuh.gd
var move = load("res://KecepatanMusuh.gd").new()

#Asumsi enemy belum ketemu player
var player = null

#Memanggil variabel velocity dari KecepatanMusuh.gd
var speedData = load("res://KecepatanMusuh.gd").new()
var velocity = speedData.velocity

#Memanggil variabel run_speed dari KecepatanMusuh.gd 
var run = load("res://KecepatanMusuh.gd").new()
var run_speed = run.run_speed

#Memanggil variabel accel dari KecepatanMusuh.gd
var akselerasi = load("res://KecepatanMusuh.gd").new()
var accel = akselerasi.accel

#Memanggil enumerator STATE dari State.gd
const state = preload("res://State.gd")

#Jarak toleransi antara enemy dengan player 
var tolerance = 4.0

#Variabel untuk posisi awal enemy
onready var start_position = global_position

#Variabel untuk mengetahui posisi target/player
#Digunakan pada state wander
onready var target_position = global_position 

#Mengubah posisi enemy secara random saat diluar jangkauan target
func update_target_position():
	#Mengatur jarak enemy saat wander 
	var target_vector = Vector2(rand_range(-32, 32), rand_range(-32, 32))
	#Update posisi
	target_position = start_position + target_vector

#Mengatur enemy untuk berhenti pada jarak tertentu
func is_at_target_position(): 
	# Akan berhenti saat target +/- toleransi
	return (target_position - global_position).length() < tolerance

#Fungsi untuk enemy berpikir memilih posisi secara random
func enemy_idle():
	$Timer.start(rand_range(0,3))
	
#Membuat enemy bergerak saat wander dalam posisi yang sudah ditetapkan (target_position)
func accelerate_to_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	accelerate(acceleration_vector)

#Aksi enemy idling
func _ready():
	state_enemy = state.STATE.IDLE 
	update_target_position()
	$Timer.one_shot = true

#Aksi enemy chasing player jika didalam jangkauan
func _on_Area2D_body_entered(body): 
	if "Player" in body.name:
		player = body
		state_enemy = state.STATE.CHASE

#Aksi enemy wandering jika player diluar jangkauan
func _on_Area2D_body_exited(body): 
	if "Player" in body.name:
		player = null
		state_enemy = state.STATE.WANDER

#Melakukan proses enemy
func _physics_process(delta):
	#Untuk Enemy
	match state_enemy: 
		#Lakukan aksi IDLE
		state.STATE.IDLE:
			velocity = Vector2.ZERO
			#Transisi Enemy wandering
			if $Timer.is_stopped():
				state_enemy = state.STATE.WANDER
				update_target_position()
			
		#Lakukan aksi CHASE
		state.STATE.CHASE:
			if not (player == null):
				velocity = position.direction_to(player.global_position) * run_speed * 100 * delta
				
		#Lakukan aksi Wander
		state.STATE.WANDER:
			move.accelerate_to_point(target_position, accel * delta)
			#Transisi Enemy idling
			if is_at_target_position():
				state_enemy = state.STATE.IDLE
				enemy_idle()
	velocity = move_and_slide(velocity, Vector2.UP)

