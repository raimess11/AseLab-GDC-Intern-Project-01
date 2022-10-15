#Codingan input nama leaderboard

extends CanvasLayer

onready var selector_one = $TextureRect/Selector
onready var tombol = $TextureRect/Button
onready var text = $TextureRect/LineEdit

var current_selection = 0

func _ready():
	text.text = " klik 2x untuk mengetik"
	set_current_selection(0)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)

func handle_selection(_current_selection):
	if _current_selection == 0:
		get_tree().change_scene("res://World.tscn")
		queue_free()

func set_current_selection(_current_selection):
	selector_one.text = ""
	if _current_selection == 0:
		selector_one.text = ">"

func _on_Button_pressed():
	tombol.visible = false
	text.text = ""
