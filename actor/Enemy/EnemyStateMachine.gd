extends KinematicBody2D

#State apa saja yang terdapat dalam enemy/musuh
enum STATE {
	IDLE,
	WANDER,
	CHASE
}

#Variabel buat animasi enemy searah dengan player
var facing = Vector2.ZERO

#Manggil node animation tree
onready var animationTree = get_node("AnimationTree")

#Untuk implementasiin animasi
onready var animationState = animationTree.get("parameters/playback")

#Manggil node player
onready var target = get_parent().get_node("Player")

#Indeks posisi
var indeksPost = 0

#Titik posisi musuh saat wandering
export var posisiWander = [Vector2(100,100), Vector2(100, -50), Vector2(30, 30)]

#Atur kecepatan enemy
export var run_speed = 50

#Variabel untuk kondisi state enemy
var state_enemy

#atur akselerasi enemy
export var akselerasi = 300

# Atur toleransi jarak dengan player
export var tolerance = 4.0

#Variabel untuk menggerakkan sprite
var velocity = Vector2.ZERO setget set_velocity 

#Asumsi enemy belum ketemu player
var player = null

#nambah ini biar kalo enemynya sama, tp pengen beberapa ga ada pistol
#bisa tinggal di uncheck di editor
export var has_gun = true

#Variabel untuk posisi awal 
#Bernilai null
onready var start_position = global_position

#Variabel untuk mengetahui posisi target/player
#Bernilai null
#Digunakan pada state wander
onready var target_position = global_position

#Ngatur arah animasi enemy sesuai dengan arah player
func set_velocity(value):
	velocity = value
	facing = velocity.normalized()

#Aksi enemy idling
func _ready():
	state_enemy = STATE.IDLE 
	update_target_position()
	$Timer.one_shot = true
	if not has_gun :
		$Gun.queue_free()
		
#Mengubah posisi enemy secara manual menggunakan array saat diluar jangkauan target
func update_target_position():
	#Inisialisasi posisi awal
	var target_vector = posisiWander[indeksPost]
	#update posisi
	target_position = start_position + target_vector
	#Untuk berhenti pada jarak tertentu
	if is_at_target_position():
		indeksPost += 1
		if indeksPost > posisiWander.size()-1:
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
	self.velocity += acceleration_vector
	self.velocity = velocity.clamped(run_speed)

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
			self.velocity = facing
			animationState.travel("Idle")
			set_anim_state()
			#Transisi Enemy wandering
			if $Timer.is_stopped():
				state_enemy = STATE.WANDER
				update_target_position()
			
		#Lakukan aksi CHASE
		STATE.CHASE:
			if not (player == null):
				animationState.travel("Walk")
				set_anim_state()
				#Enemy akan berhenti pada jarak tertentu dan siap mau nembak
				if target.global_position.distance_to(global_position) < 100:
					aim_still()
					if velocity == Vector2.ZERO:
						set_velocity(facing)
						animationState.travel("Aim")
						animationState.travel("Shoot")
						set_anim_state()
				else:
					self.velocity = position.direction_to(player.global_position) * run_speed * 100 * delta
				
		#Lakukan aksi WANDER
		STATE.WANDER:
			accelerate_to_point(target_position, akselerasi * delta)
			animationState.travel("Walk")
			set_anim_state()
			#Transisi Enemy idling
			if is_at_target_position():
				state_enemy = STATE.IDLE
				enemy_idle()
	self.velocity = move_and_slide(velocity, Vector2.UP)

#Animasi enemy state	
func set_anim_state():
	animationTree.set("parameters/Walk/blend_position", facing)
	animationTree.set("parameters/Shoot/blend_position", facing)
	animationTree.set("parameters/Idle/blend_position", facing)
	animationTree.set("parameters/Aim/blend_position", facing)

#Untuk enemy berhentinya	
func aim_still():
	velocity = Vector2.ZERO
