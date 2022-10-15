extends TileMap

onready var tween = get_node("Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Area2D_body_entered(body):
	if body.get_name() == "Player" :
		tween.interpolate_property(self, "modulate",
		 Color(1,1,1,1), Color(1,1,1,0.25), 0.5,
		 Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _on_Area2D_body_exited(body):
	if body.get_name() == "Player" :
		tween.interpolate_property(self, "modulate",
		 Color(1,1,1,0.25), Color(1,1,1,1), 0.5,
		 Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
