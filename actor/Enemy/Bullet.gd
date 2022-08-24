extends Area2D

export var bullet_speed = 1500

func _ready() :
	#set as top level biar ga ikut berubah kalo parentnya berubah
	set_as_toplevel(true)

#set arah dan posisi peluru
func _process(delta):
	position += (Vector2.RIGHT*bullet_speed).rotated(rotation) * delta

func _physics_process(delta):
	yield(get_tree().create_timer(0.01),"timeout")
	#kalo pakai spritesheet, set frame yg dipake
	#$Sprite.frame = 1
	set_physics_process(false)

#kalo pakai node ini, nanti keluar layar peluru dihapus
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

#kalo kena body lain, hapus
#kalo kena body yg punya method damage, hapus trus kurangin sebanyak value
func _on_EnemyBullet_body_entered(body):
	if not (body.is_a_parent_of(self) or body.get_parent() == get_parent()) :
		queue_free()
	if body.has_method("damage") :
		body.damage(10)

#kalo kena area selain diri sendiri, hapus
func _on_EnemyBullet_area_entered(area):
	if not (area.is_a_parent_of(self) or area.get_parent() == get_parent()) :
		pass #kalo perlu, pass nya dihapus, uncomment queue free
		#queue_free()
