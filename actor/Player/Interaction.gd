extends Area2D

#bikin editable var di inspector
export var interaction_parent : NodePath

signal on_interactable_changed(newInteractable)

#interaction target adalah node yang masuk ke area2D
var interaction_target : Node

#Cek tiap frame apa ada target dan player klik tombol interact
func _process(_delta) :
	if (interaction_target != null and Input.is_action_just_pressed("interact")) :
		#kalo punya method interaction_interact, jalanin
		if (interaction_target.has_method("interaction_interact")) :
			interaction_target.interaction_interact(self)


func _on_Interaction_body_entered(body) :
	#init bisa interaksi ke false
	var canInteract := false
	
	#kalau body yang masuk ada method bisa interaksi, ganti ke true
	if (body.has_method("interaction_can_interact")) :
		canInteract = body.interaction_can_interact(get_node(interaction_parent))
	
	#kalo ga ada, berhentiin function
	if not canInteract :
		return
	
	#set target interaksi ke body yang masuk, kasi sinyal
	interaction_target = body
	emit_signal("on_interactable_changed", interaction_target)

func _on_Interaction_body_exited(body) :
	#kalo body yang keluar sama dengan target, null kan
	if (body == interaction_target) :
		interaction_target = null
		emit_signal("on_interactable_changed", null)
