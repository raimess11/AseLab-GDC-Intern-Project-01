extends Sprite

var can_fire = true
var bullet = preload("res://actor/Enemy/EnemyBullet.tscn")
var bullet_instance

enum INDICATION_STATE{
	black,
	yellow,
	red
}

#signal indikasi
signal yellow(enemyName)
signal red(bulletName)
signal black(enemyName, bulletName)

#untuk indikasi dodge player
var indicationState = INDICATION_STATE.black
var enemyAiming = false

onready var player = get_node("/root/World/Player")
onready var dodge = player.get_node("Dodge")
onready var indicator = get_node("../AttackIndicator")
onready var indicator_player = get_node("../AttackIndicator/IndicatorPlayer")

#untuk nama bullet biar gambang dibedakan
var timeStart: int = 0
var timeNow: int = 0
var bulletId: int = 0

#init posisi
func _ready():
	set_as_toplevel(true)
	position = get_parent().position
	indicator.hide()
	timeStart = OS.get_unix_time()
	connect("yellow",dodge,"yellowTriggered")
	connect("red",dodge,"redTriggered")
	connect("black",dodge,"blackTriggered")
	



func _physics_process(delta):
#membuat id dari waktu
	timeNow = OS.get_unix_time()
	bulletId = timeNow - timeStart
#lerp posisi biar muternya smooth
	position.x = lerp(position.x, get_parent().position.x, 0.5)
	position.y = lerp(position.y, get_parent().position.y, 0.5)
	#kalo di kiri(kanan?), flip biar ga kebalik pistolnya
	flip_v = true if player.global_position.x < global_position.x else false
	
	#cek jarak pistol sama player
	if (global_position.distance_to(player.global_position) < 350) :
		dodge.addEnemyList(get_parent().name, indicationState)
		#suruh pistol liat player
		look_at(player.global_position)
		if (can_fire and $RayCast2D._collider_is_player()) :
			if indicator_player.is_playing() :
				return
			else :
				#kalo raycast hit ke player, tembak
				bullet_instance = bullet.instance()
				indicator.show()
				bullet_instance.rotation = rotation + rand_range(-0.1, 0.1)
				bullet_instance.global_position = $Muzzle.global_position
				indicator_player.play("Warning")
				yield(indicator_player, "animation_finished")
				indicator_player.play("Attack")
				indicator_player.playback_speed = 0.5
				indicationState = INDICATION_STATE.yellow
				emit_signal("yellow", get_parent().name)
				yield(indicator_player, "animation_finished")
				bullet_instance.name = "{0}bullet_{1}".format([bulletId, get_parent().name])
				var bullet_name = bullet_instance.name
				get_parent().add_child(bullet_instance)
				bullet_instance.connect("tree_exited", dodge, "bulletQueueFree", [bullet_name])
				emit_signal("red", get_parent().get_node(bullet_name))
				indicationState = INDICATION_STATE.red
				can_fire = false
				yield(get_tree().create_timer(2),"timeout")
				indicationState = INDICATION_STATE.black
				
				emit_signal("black",get_parent().name,bullet_name)
				if get_parent().has_node("{0}bullet_{1}".format([bulletId, get_parent().name])):
					bullet_instance.isUneffectedByDodge = true
				can_fire = true
	else:
		enemyAiming = false
		dodge.deleteEnemyList(get_parent().name)
		
		
	
