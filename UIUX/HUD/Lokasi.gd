extends Node2D
onready var lokasi = $Player/HUD/Lokasi
func _ready():
	pass

func _on_Player_area_entered(area):
	if area.name != "Interaction":
		lokasi.text = area.name
		print(area.name)

