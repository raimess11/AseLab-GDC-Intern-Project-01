extends KinematicBody2D

#State apa saja yang terdapat dalam enemy/musuh
enum STATE {
	IDLE,
	WANDER,
	CHASE
}

#Indeks posisi
var indeksPost = 0

#Titik posisi musuh saat wandering
var posisiWander = [Vector2(100,100), Vector2(100, -50), Vector2(30, 30)]

#Atur kecepatan enemy
var run_speed = 100

#Variabel untuk kondisi state enemy
var state_enemy

#atur akselerasi enemy
var akselerasi = 300

# Atur toleransi jarak dengan player
var tolerance = 4.0

#Variabel untuk menggerakkan sprite
var velocity = Vector2.ZERO

#Asumsi enemy belum ketemu player
var player = null

#Variabel untuk posisi awal 
#Bernilai null
onready var start_position = global_position

#Variabel untuk mengetahui posisi target/player
#Bernilai null
#Digunakan pada state wander
onready var target_position = global_position

#Aksi enemy idling
func _ready():
	state_enemy = STATE.IDLE 
	update_target_position()
	$Timer.one_shot = true

#Mengubah posisi enemy secara random saat diluar jangkauan target
func update_target_position():
	#Inisialisasi posisi awal
	var target_vector = posisiWander[indeksPost]
	#update posisi
	target_position = start_position + target_vector
	#Untuk berhenti pada jarak tertentu
	if is_at_target_position():
		indeksPost += 1
		if indeksPost > 2:
			indeksPost = 0 

#Mengatur enemy untuk berhenti pada jarak tertentu
func is_at_target_position(): 
	# Akan berhenti saat target +/- toleransi
	return (target_position - global_position).length() < tolerance

#Membuat enemy bergerak saat wander dalam posisi yang sudah ditetapkan (target_position)
func accelerate_to_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	accelerate(acceleration_vector)

#Memungkinkan enemy untuk bergerak
func accelerate(acceleration_vector):
	velocity += acceleration_vector
	velocity = velocity.clamped(run_speed)

#Fungsi untuk enemy berpikir memilih posisi secara random
func enemy_idle():
	$Timer.start(rand_range(0,3))

#Aksi enemy chasing player jika didalam jangkauan
func _on_Area2D_body_entered(body): 
	if "Player" in body.name:
		player = body
		state_enemy = STATE.CHASE

#Aksi enemy wandering jika player diluar jangkauan
func _on_Area2D_body_exited(body): 
	if "Player" in body.name:
		player = null
		state_enemy = STATE.WANDER

#Melakukan proses enemy
func _physics_process(delta):
	#Untuk Enemy
	match state_enemy: 
		#Lakukan aksi IDLE
		STATE.IDLE:
			velocity = Vector2.ZERO
			#Transisi Enemy wandering
			if $Timer.is_stopped():
				state_enemy = STATE.WANDER
				update_target_position()
			
		#Lakukan aksi CHASE
		STATE.CHASE:
			if not (player == null):
				velocity = position.direction_to(player.global_position) * run_speed * 100 * delta
				
		#Lakukan aksi WANDER
		STATE.WANDER:
			accelerate_to_point(target_position, akselerasi * delta)
			#Transisi Enemy idling
			if is_at_target_position():
				state_enemy = STATE.IDLE
				enemy_idle()
	velocity = move_and_slide(velocity, Vector2.UP)
