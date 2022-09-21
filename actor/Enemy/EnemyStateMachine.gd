extends KinematicBody2D

#State apa saja yang terdapat dalam enemy/musuh
enum STATE {
	IDLE,
	WANDER,
	CHASE
}
enum States { IDLE, FOLLOW }
#Indeks posisi
var indeksPost = 0
var _state = States.IDLE
#Titik posisi musuh saat wandering
export var posisiWander = [Vector2(100,100), Vector2(100, -50), Vector2(30, 30)]
var _velocity = Vector2()
const MASS = 10.0
const ARRIVE_DISTANCE = 10.0
var _target_point_world = Vector2()
var _target_position = Vector2()
#Atur kecepatan enemy
var run_speed = 50

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

#Jalan dari enemy ke player
var _path: Array = []
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

#Aksi enemy idling
func _ready():
	yield(get_tree(), "idle_frame") #Untuk meminimalisir bug
	#Deteksi apakah ada grup player dan navigasi di scene
	var tree = get_tree()
	if tree.has_group("Grounds"):
		levelNavigation = tree.get_nodes_in_group("Grounds")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	state_enemy = STATE.IDLE 
	update_target_position()
	$Timer.one_shot = true
	if not has_gun :
		$Gun.queue_free()
	_change_state(States.IDLE)

#Mengubah posisi enemy secara random saat diluar jangkauan target
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
			velocity = Vector2.ZERO
			#Transisi Enemy wandering
			if $Timer.is_stopped():
				state_enemy = STATE.WANDER
				update_target_position()

		#Lakukan aksi CHASE
		STATE.CHASE:
			if player:
				los.look_at(player.global_position)
				check_player_in_detection()
				if _state != States.FOLLOW:
					return
				var _arrived_to_next_point = _move_to(_target_point_world)
				if _arrived_to_next_point:
					_path.remove(0)
					if len(_path) == 0:
						_change_state(States.IDLE)
						return
					_target_point_world = _path[0]
					print(_path)
		#Lakukan aksi WANDER
#		STATE.WANDER:
#			accelerate_to_point(target_position, akselerasi * delta)
#			#Transisi Enemy idling
#			if is_at_target_position():
#				state_enemy = STATE.IDLE
#				enemy_idle()
	velocity = move_and_slide(velocity, Vector2.UP)
#func _process(_delta):
#	if _state != States.FOLLOW:
#		return
#	var _arrived_to_next_point = _move_to(_target_point_world)
#	if _arrived_to_next_point:
#		_path.remove(0)
#		if len(_path) == 0:
#			_change_state(States.IDLE)
#			return
#		_target_point_world = _path[0]
#	print(_path)
#FUNGSI BUAT PATHFINDING
#Fungsi buat jalan sesuai dengan path
#Fungsi buat check visibilitas player oleh enemy
func check_player_in_detection():
	var collider = los.get_collider()
	if collider:
		player_spotted = true
		_target_position = player.position
	_change_state(States.FOLLOW)
	print("raycast collided")    # Debug purposes

func _move_to(world_position):
	var desired_velocity = (world_position - position).normalized() * run_speed
	var steering = desired_velocity - _velocity
	_velocity += steering / MASS
	position += _velocity * get_process_delta_time()
	rotation = _velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE

func _change_state(new_state):
	if new_state == States.FOLLOW:
		_path = get_parent().get_node("TileMap").get_astar_path(position, _target_position)
		if not _path or len(_path) == 1:
			_change_state(States.IDLE)
			return
		# The index 0 is the starting cell.
		# We don't want the character to move back to it in this example.
		_target_point_world = _path[1]
	_state = new_state
