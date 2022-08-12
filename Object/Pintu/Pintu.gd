extends StaticBody2D

#ngasi tau node ini bisa interaksi
func interaction_can_interact(interactionComponentParent : Node) -> bool :
	return interactionComponentParent is Player

#UI text yang mau dimunculin kalo masuk radius interaksi
func interaction_get_text() -> String:
	return "Press E to Open Door"

#yang dilakuin pas interaksi
# warning-ignore:unused_argument
func interaction_interact(interactionComponentParent : Node) -> void :
	$AnimationPlayer.play("Open") #Animasi Buka
	yield($AnimationPlayer,"animation_finished")
	$Area2D.disabled = true #Disable Collision
	yield(get_tree().create_timer(5.0), "timeout") #Jeda Kebuka
	$AnimationPlayer.play_backwards("Open") #Animasi Tutup
	yield($AnimationPlayer,"animation_finished")
	$Area2D.disabled = false #Enable Collision
