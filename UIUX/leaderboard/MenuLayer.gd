#ini masih codingan score di game flappy bird soalnya pas itu
#samurai of void belum ada mekanisme kill musuh yang ngebuat mekanisme
#score belum jalan
#contoh implementasinya nanti kayak gini
#https://drive.google.com/file/d/1-5XmmxBev67PMgvJ-kYITPbhCemUvcbH/view?usp=sharing 

extends CanvasLayer

signal start_game

onready var start_message = $StartMenu/StartMessage
onready var tween = $Tween
onready var score_label = $GameOverMenu/VBoxContainer/ScoreLabel
onready var high_score_label = $GameOverMenu/VBoxContainer/HighScoreLabel
onready var game_over_menu = $GameOverMenu
onready var vboxscore = $Leaderboard/PanelContainer/ListScore
onready var vboxnama = $Leaderboard/PanelContainer/ListNama
onready var Leaderboardd = $Leaderboard
var x = 0

#list nama & score untuk leaderboard

const SAVE_FILE_PATH2 = "user://wkwk359.save"
const SAVE_FILE_PATH3 = "user://wkwk360.save"
const SAVE_FILE_PATH4 = "user://wkwk361.save"
var game_started = false

func _input(event):
	if event.is_action_pressed("flap") && !game_started:
		emit_signal("start_game")
		tween.interpolate_property(start_message, "modulate:a", 1, 0, 0.5)
		tween.start()
		game_started = true

class sortnameandscore:
	static func sort_ascending(a,b):
		if a[1] > b[1]:
			return true
		return false

func Leaderboard(score, highscore, listscore, listnama, listleaderboard):
	var max_name := min(listnama.size(), 10)
	for i in range(max_name) :
		x += 1
		listleaderboard.sort_custom(sortnameandscore, "sort_ascending")
		var namascore = listleaderboard[i]
		var labelscore = Label.new()
		var labelnama = Label.new()
		if namascore[0] != null :
			labelscore.text =  String(namascore[1])
			labelscore.set_align(0)
			labelscore.set_clip_text(true)
			vboxnama.add_child(labelnama)
			labelnama.text =  String(namascore[0])
			labelscore.set_align(2)
			labelscore.set_clip_text(true)
			vboxscore.add_child(labelscore)
	
func UpdateLeaderboard(score, highscore, listscore, listnama, listleaderboard):
	print(x)
	if vboxscore.get_child_count() < 10 :	
		var namascore = listleaderboard[x]
		print("Player baru : ",namascore)
		var labelscore = Label.new()
		var labelnama = Label.new()
		labelscore.text =  String(namascore[1])
		labelscore.set_align(0)
		labelscore.set_clip_text(true)
		vboxnama.add_child(labelnama)
		labelnama.text =  String(namascore[0])
		labelscore.set_align(2)
		labelscore.set_clip_text(true)
		vboxscore.add_child(labelscore)
		print("List Leaderboard Update : ",listleaderboard)

func init_game_over_menu(score, highscore, listscore, listnama):
	score_label.text = "SCORE: " + str(score)
	high_score_label.text = "BEST: " + str(highscore)
	
	game_over_menu.visible = true
	
func _on_RestartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
