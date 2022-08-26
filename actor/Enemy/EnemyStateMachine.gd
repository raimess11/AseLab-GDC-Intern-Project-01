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
var path: Array = []
var levelNavigation: Navigation2D = null

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

#Musuh menunggu/mikir mau ke jalan yang mana
func enemy_idle():
	$Timer.start(rand_range(0,3))
	
#Aksi IDLE
func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Navigasi"):
		levelNavigation = tree.get_nodes_in_group("Navigasi")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	state_enemy = STATE.IDLE # Replace with function body.
	#update_target_position()
	$Timer.one_shot = true

#Aksi Chase
func _on_Area2D_body_entered(body): # Replace with function body.
	if "Player" in body.name:
		player = body
		state_enemy = STATE.CHASE
		print("masuk")

#Aksi WANDER
func _on_Area2D_body_exited(body): # Replace with function body.
	if "Player" in body.name:
		player = null
		state_enemy = STATE.WANDER
		print("keluar")

func _physics_process(delta):
	#Untuk Enemy
	match state_enemy: 
		#Lakukan aksi IDLE
		STATE.IDLE:
			velocity = Vector2.ZERO
			if $Timer.is_stopped():
				state_enemy = STATE.WANDER
				update_target_position()
			
		#Lakukan aksi CHASE
		STATE.CHASE:
			if player and levelNavigation:
				generate_path()
				navigate()
		#Lakukan aksi WANDER
		STATE.WANDER:
			accelerate_to_point(target_position, akselerasi * delta)
			if is_at_target_position():
				state_enemy = STATE.IDLE
				enemy_idle()
	velocity = move_and_slide(velocity, Vector2.UP)

func navigate():    # Define the next position to go to
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * run_speed
		
		# If reached the destination, remove this point from path array
		if global_position == path[0]:
			path.pop_front()

func generate_path():
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)
