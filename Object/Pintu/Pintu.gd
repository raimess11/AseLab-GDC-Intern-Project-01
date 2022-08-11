extends StaticBody2D

#Fungsi membuka dan menutup pintu
func _on_Area2D_body_entered(_body):
	$AnimationPlayer.play("Buka") #Jalan animasi buka
	yield($AnimationPlayer,"animation_finished")
	$Area2D.disabled = true #Disable collision
	yield(get_tree().create_timer(5.0), "timeout") #Delay pintu kebuka
	$AnimationPlayer.play_backwards("Buka") #Animasi tutup
	yield($AnimationPlayer,"animation_finished")
	$Area2D.disabled = false #Enable collision
