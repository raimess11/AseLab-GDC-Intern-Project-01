extends StaticBody2D

func _on_Area2D_body_entered(_body):
	$AnimationPlayer.play("Buka")
	yield($AnimationPlayer,"animation_finished")
	$Area2D.disabled = true
	yield(get_tree().create_timer(5.0), "timeout")
	$AnimationPlayer.play_backwards("Buka")
	yield($AnimationPlayer,"animation_finished")
	$Area2D.disabled = false
