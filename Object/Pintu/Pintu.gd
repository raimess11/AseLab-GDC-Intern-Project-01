extends StaticBody2D

#status pintu (false=tutup/true=buka)
var status = false

#ngasi tau node ini bisa interaksi
func interaction_can_interact(interactionComponentParent : Node) -> bool :
	return interactionComponentParent is Player

#UI text yang mau dimunculin kalo masuk radius interaksi
func interaction_get_text() -> String:
	return "Press E to Open or Close Door"

#yang dilakuin pas interaksi
func interaction_interact(interactionComponentParent : Node) -> void :
	#cek status pintu
	if status == false:
		#jalanin animasi
		$AnimationPlayer.play("open")
		yield($AnimationPlayer,"animation_finished")
		#ubah status pintu jadi true(kebuka)
		status = true
	else:
		$AnimationPlayer.play_backwards("open")
		yield($AnimationPlayer,"animation_finished")
		status = false
