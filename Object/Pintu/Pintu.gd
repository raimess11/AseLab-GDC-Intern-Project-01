extends StaticBody2D

func _on_Area2D_body_entered(_body):
	$AnimationPlayer.play("Buka")
	yield($AnimationPlayer,"animation_finished")
	queue_free()
