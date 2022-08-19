extends CanvasLayer

const CHAR_READ_RATE = 0.05

onready var textbox_container = $TextboxContainer
onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label

enum State{
	READY,
	READING,
}

#Buat naruh text di queue_text, jadi bisa ada 9 baris text yang bakal ditampilin
#3 baris - 3 baris, kalau kurang tinggal hapus beberapa queue textnya, kalau mau tambah
#tinggal tambahin, nanti kalo pencet enter bakal nampilin text selanjutnya, urutan nampilinnya
#dari queue text paling atas ke queue text baris bawah 
#kalo textnya udah habis kalo di enter bakal ilang textnya

var current_state = State.READY
var text_queue = []

func _ready():
	print("Starting state to: State.READY")
	hide_textbox()
	queue_text("First text queued up!")
	queue_text("Second text queued up!")
	queue_text("Third text queued up!")
	
func _process(delta):
	match current_state:
		State.READY:
			if !text_queue.empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				hide_textbox()

func queue_text(next_text):
	text_queue.push_back(next_text)

func hide_textbox():
	start_symbol.text = ""
	label.text = ""
	textbox_container.hide()
	
func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()

func display_text():
	var next_text = text_queue.pop_front()
	label.text = next_text
	change_state(State.READING)
	show_textbox()
	$Tween.interpolate_property(label,"percent_visible", 0.0, 1.0, len(next_text) * CHAR_READ_RATE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Changing state to: State.READY")
		State.READING:
			print("Changing state to: State.READING")
