extends Control
class_name InteractionComponentUI

#path ke node area2D interaction
export var interaction_component_nodepath : NodePath

export var interaction_texture_nodepath : NodePath
export var interaction_text_nodepath : NodePath
export var interaction_default_texture : Texture
export var interaction_default_text : String

var fixed_position : Vector2

func _ready():
	# connect diri sendiri ke komponen sinyal nya
	get_node(interaction_component_nodepath).connect("on_interactable_changed", self, "interactable_target_changed", [], CONNECT_DEFERRED)
	
	# hide on ready
	hide()
	
func _process(delta : float):
	#karena UI nya child dari player, ngikutin player
	set_global_position(fixed_position)

func interactable_target_changed(newInteractable : Node) -> void:
	#newInteractable objek interactnya, kalau null berarti udh ga deket objek, hide UI
	if (newInteractable == null):
		hide()
		return
		
	#Kalo objek ketemu, bikin var texture sama text
	#biar icon dan teks yang dimunculin bisa custom tiap objek
	var interaction_texture := interaction_default_texture
	var interaction_text := interaction_default_text
	
	# kalo punya custom texture, overwrite var nya. klo ga punya, default
	if (newInteractable.has_method("interaction_get_texture")):
		interaction_texture = newInteractable.interaction_get_texture()
	
	# Text juga
	if (newInteractable.has_method("interaction_get_text")):
		interaction_text = newInteractable.interaction_get_text()
	
	# overwrite texture dan text di node objek lewat get node
	get_node(interaction_texture_nodepath).texture = interaction_texture
	get_node(interaction_text_nodepath).text = interaction_text
	
	# Atur posisi UI nya muncul dimana (atas objek)
	fixed_position = Vector2(newInteractable.get_global_position().x - 25, newInteractable.get_global_position().y - 50)
	
	# trus pindahin
	self.set_global_position(fixed_position)
	
	# dan Show karna bukan null
	show()
