extends MarginContainer

onready var selector_one = $CenterContainer/VBoxContainer/Selection/VBoxContainer/CenterContainer/HBoxContainer/Selector
onready var selector_two = $CenterContainer/VBoxContainer/Selection/VBoxContainer/CenterContainer2/HBoxContainer/Selector
onready var selector_three = $CenterContainer/VBoxContainer/Selection/VBoxContainer/CenterContainer3/HBoxContainer/Selector

var current_selection = 0

func _ready():
	set_current_selection(0)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_down") and current_selection < 2:
		current_selection +=1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		current_selection -=1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)

#nanti kalo udah ada levelnya get_tree().change_scene("res://World.tscn") diubah
#ke scene levelnya jadi nanti di main menu kalo klik start sama tutorial scenenya beda
#sementara sama dulu ke World.tscn
func handle_selection(_current_selection):
	if _current_selection == 0:
		get_tree().change_scene("res://World.tscn")
		queue_free()
	elif _current_selection == 1:
		get_tree().change_scene("res://World.tscn")
		queue_free()
	elif _current_selection == 2:
		get_tree().quit()

func set_current_selection(_current_selection):
	selector_one.text = ""
	selector_two.text = ""
	selector_three.text = ""
	if _current_selection == 0:
		selector_one.text = ">"
	elif _current_selection == 1:
		selector_two.text = ">"
	elif _current_selection == 2:
		selector_three.text = ">"
		
