extends StaticBody2D

#status switch (false=mati/true=hidup)
var status = false

#ngasi tau node ini bisa interaksi
func interaction_can_interact(interactionComponentParent : Node) -> bool :
	return interactionComponentParent is Player

#UI text yang mau dimunculin kalo masuk radius interaksi
func interaction_get_text() -> String:
	return "Press E to Interact"

#yang dilakuin pas interaksi
func interaction_interact(interactionComponentParent : Node) -> void :
	#cek status pintu
	if status == false:
		#jalanin animasi
		$AnimationPlayer.play("switch")
		yield($AnimationPlayer,"animation_finished")
		#ubah status switch jadi true(aktif)
		status = true
		#lanjut buat apa yang akan dilakukan switch ini pas nyala
	else:
		$AnimationPlayer.play_backwards("switch")
		yield($AnimationPlayer,"animation_finished")
		status = false
		#lanjut buat apa yang akan dilakukan switch ini pas mati
	
