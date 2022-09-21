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

#Jalan dari enemy ke player
var path: Array = []
#Variabel detekti tilemap yang bisa dinavigasi
var levelNavigation: Navigation2D = null
#Variabel apakah enemy ngeliat playernya
var player_spotted: bool = false

#nambah ini biar kalo enemynya sama, tp pengen beberapa ga ada pistol
#bisa tinggal di uncheck di editor
export var has_gun = true

onready var los = $LineOfSight
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
	yield(get_tree(), "idle_frame") #Untuk meminimalisir bug
	#Deteksi apakah ada grup player dan navigasi di scene
	var tree = get_tree()
	if tree.has_group("Navigasi"):
		levelNavigation = tree.get_nodes_in_group("Navigasi")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
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
		print("masuk")


#Aksi enemy wandering jika player diluar jangkauan
func _on_Area2D_body_exited(body): 
	if "Player" in body.name:
		player = null
		state_enemy = STATE.WANDER
		print("keluar")

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
				los.look_at(player.global_position)
				check_player_in_detection()
				if player_spotted:
					generate_path()
					navigate()
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


#FUNGSI BUAT PATHFINDING
#Fungsi buat jalan sesuai dengan path
func navigate():
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * run_speed
		
		# If reached the destination, remove this point from path array
		if global_position == path[0]:
			path.pop_front()

func generate_path():
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)

#Fungsi buat check visibilitas player oleh enemy
func check_player_in_detection():
	var collider = los.get_collider()
	if collider:
		player_spotted = true
		print("raycast collided")    # Debug purposes

