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

#ambil node anim player anim indikatornya
onready var attack_ind = $indicator.get_node("Attack").get_node("AnimationPlayer")
onready var warning_ind = $indicator.get_node("Warning").get_node("AnimationPlayer")
onready var start_position = global_position
onready var target_position = global_position
onready var bullet_scene = preload("res://Object/Bullet.tscn")

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
	$indicator/Attack.hide()
	$indicator/Warning.hide()

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

func fire() :
	match state_enemy :
		STATE.CHASE :
			#ambil peluru dari scene, set posisi dan player var
			var bullet = bullet_scene.instance()
			bullet.position = get_global_position()
			bullet.player = player
			#tambahin peluru yg baru dibuat ke child
			get_parent().add_child(bullet)
	#timer 5 detik
	$BulletTimer.set_wait_time(5)

func _physics_process(delta):
	#Untuk Enemy
	match state_enemy: 
		#Lakukan aksi IDLE
		STATE.IDLE:
			velocity = Vector2.ZERO
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
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_BulletTimer_timeout():
	#reset animation ke 0 detik
	warning_ind.seek(0.2,true)
	attack_ind.seek(0.2,true)
	#play dan show animation 
	warning_ind.play("warning")
	$indicator/Warning.show()
	#kalau animation selesai, yield sinyal selesai trus hide
	yield(warning_ind,"animation_finished")
	$indicator/Warning.hide()
	#timer kalau perlu
	yield(get_tree().create_timer(0.3), "timeout")
	#hal yg sm dengan yg atas
	attack_ind.play("attack")
	$indicator/Attack.show()
	yield(attack_ind,"animation_finished")
	$indicator/Attack.hide()
	fire()
