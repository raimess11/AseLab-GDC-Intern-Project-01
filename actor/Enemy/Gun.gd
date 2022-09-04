extends Sprite

var can_fire = true
var bullet = preload("res://actor/Enemy/EnemyBullet.tscn")

onready var player = get_node("/root/World/Player")
onready var indicator = get_node("../AttackIndicator")
onready var indicator_player = get_node("../AttackIndicator/IndicatorPlayer")

#init posisi
func _ready():
	set_as_toplevel(true)
	position = get_parent().position
	indicator.hide()


func _physics_process(delta):
#lerp posisi biar muternya smooth
	position.x = lerp(position.x, get_parent().position.x, 0.5)
	position.y = lerp(position.y, get_parent().position.y, 0.5)
	#kalo di kiri(kanan?), flip biar ga kebalik pistolnya
	flip_v = true if player.global_position.x < global_position.x else false
	
	#cek jarak pistol sama player
	if (global_position.distance_to(player.global_position) < 350) :
		#suruh pistol liat player
		look_at(player.global_position)
		if (can_fire and $RayCast2D._collider_is_player()) :
			if indicator_player.is_playing() :
				return
			else :
				#kalo raycast hit ke player, tembak
				indicator.show()
				var bullet_instance = bullet.instance()
				bullet_instance.rotation = rotation + rand_range(-0.1, 0.1)
				bullet_instance.global_position = $Muzzle.global_position
				indicator_player.play("Warning")
				yield(indicator_player, "animation_finished")
				indicator_player.play("Attack")
				yield(indicator_player, "animation_finished")
				get_parent().add_child(bullet_instance)
				can_fire = false
				yield(get_tree().create_timer(1),"timeout")
				can_fire = true
	
