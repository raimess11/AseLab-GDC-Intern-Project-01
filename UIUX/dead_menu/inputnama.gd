extends CanvasLayer

onready var selector_one = $ColorRect/TextureRect/Selector
onready var tombol = $TextureRect/Button
onready var text = $TextureRect/LineEdit
onready var nama = $ColorRect
onready var line_edit = get_node("ColorRect/TextureRect/LineEdit")
signal get_name(name)

var current_selection = 0

func _ready():
	line_edit.grab_focus()
	set_current_selection(0)
	
func focus():
	line_edit.grab_focus()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)

func handle_selection(_current_selection):
	if _current_selection == 0:
		emit_signal("get_name",line_edit.text)
		queue_free()

func set_current_selection(_current_selection):
	selector_one.text = ""
	if _current_selection == 0:
		selector_one.text = ">"
