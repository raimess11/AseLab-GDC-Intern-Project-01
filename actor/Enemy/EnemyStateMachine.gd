extends KinematicBody2D

enum STATE {
	IDLE,
	WANDER,
	CHASE
}

<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
=======
>>>>>>> Stashed changes
#Custom signal
signal death

#Enemy Stats
var health = 200
var health_max = 200
var health_regeneration = 1

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

>>>>>>> Stashed changes
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

#Musuh menunggu/mikir mau ke jalan yang mana
func enemy_idle():
	$Timer.start(rand_range(0,3))
	
#Aksi IDLE
func _ready():
	state_enemy = STATE.IDLE # Replace with function body.
	update_target_position()
	$Timer.one_shot = true

#Aksi Chase
func _on_Area2D_body_entered(body): # Replace with function body.
	if "Player" in body.name:
		player = body
		state_enemy = STATE.CHASE

#Aksi WANDER
func _on_Area2D_body_exited(body): # Replace with function body.
	if "Player" in body.name:
		player = null
		state_enemy = STATE.WANDER

func _physics_process(delta):
	#Untuk Enemy
	match state_enemy: 
		#Lakukan aksi IDLE
		STATE.IDLE:
<<<<<<< Updated upstream
			velocity = Vector2.ZERO
=======
			self.velocity = facing
			animationState.travel("Idle")
			set_anim_state()
			# Regenerates health
			health = min(health + health_regeneration * delta, health_max)
			#Transisi Enemy wandering
>>>>>>> Stashed changes
			if $Timer.is_stopped():
				state_enemy = STATE.WANDER
				update_target_position()
			
		#Lakukan aksi WANDER
		STATE.CHASE:
			if not (player == null):
				velocity = position.direction_to(player.global_position) * run_speed * 100 * delta
				
		#Lakukan aksi Chase
		STATE.WANDER:
			accelerate_to_point(target_position, akselerasi * delta)
			if is_at_target_position():
				state_enemy = STATE.IDLE
				enemy_idle()
<<<<<<< Updated upstream
	velocity = move_and_slide(velocity, Vector2.UP)
=======
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
<<<<<<< Updated upstream
	
=======

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
		
>>>>>>> Stashed changes
#Hit enemy
func hit(damage):
	health -= damage
	print(health)
	if health > 0:
		pass #Replace with damage code
	else:
<<<<<<< Updated upstream
		velocity = Vector2.ZERO
		$Mafia.hide()
		$CollisionShape2D.set_deferred("disabled", true)
		$Area2D.set_deferred("disabled", true)
		emit_signal("death")
		queue_free()
>>>>>>> Stashed changes
=======
		set_physics_process(false)
		#Signal untuk ke script player
		emit_signal("death")
		yield(get_tree().create_timer(1.5), "timeout")
		queue_free()
>>>>>>> Stashed changes
