extends Control

onready var selector_one = $CenterContainer/VBoxContainer/Selection/VBoxContainer/CenterContainer/HBoxContainer/Selector
onready var selector_two = $CenterContainer/VBoxContainer/Selection/VBoxContainer/CenterContainer2/HBoxContainer/Selector

var current_selection = 0

func _ready():
	set_visible(false)
	set_current_selection(0)

func _input(event):
	if event.is_action_pressed("pause"):
		set_visible(!get_tree().paused)
		get_tree().paused = !get_tree().paused
		
func _process(delta):
	if Input.is_action_just_pressed("ui_down") and current_selection < 1:
		current_selection +=1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		current_selection -=1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)
		
func handle_selection(_current_selection):
	if _current_selection == 0:
		get_tree().paused = false
		set_visible(false)
	elif _current_selection == 1:
		get_tree().change_scene("res://UIUX/main_menu/Main Menu.tscn")
		get_tree().paused = false
		queue_free()

func set_current_selection(_current_selection):
	selector_one.text = ""
	selector_two.text = ""
	if _current_selection == 0:
		selector_one.text = ">"
	elif _current_selection == 1:
		selector_two.text = ">"
