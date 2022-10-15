#ini masih codingan score di game flappy bird soalnya pas itu
#samurai of void belum ada mekanisme kill musuh yang ngebuat mekanisme
#score belum jalan
#contoh implementasinya nanti kayak gini
#https://drive.google.com/file/d/1-5XmmxBev67PMgvJ-kYITPbhCemUvcbH/view?usp=sharing 

extends Node2D

onready var hud = $HUD
onready var obstacle_spawner = $ObstacleSpawner
onready var ground = $Ground
onready var menu_layer = $MenuLayer
var popup = false

const SAVE_FILE_PATH = "user://wkwk358.save"
const SAVE_FILE_PATH2 = "user://wkwk359.save"
const SAVE_FILE_PATH3 = "user://wkwk360.save"
const SAVE_FILE_PATH4 = "user://wkwk361.save"
const SAVE_FILE_PATH5 = "user://wkwk362.save"

var listscore := []
var listnama := []
var z = 0
var listleaderboard := []
var score = 0 setget set_score
var highscore = 0

func _ready():
	obstacle_spawner.connect("obstacle_created", self, "_on_obstacle_created")
	load_z()
	load_highscore()
	load_listscore()
	load_listleaderboard()
	load_nama()
	print("List Nama : ", listnama)
	print("List Score : ", listscore)
	print("List Leaderboard : ", listleaderboard)
	menu_layer.Leaderboard(score, highscore, listscore, listnama, listleaderboard)

func on_get_name(name):
	if name != "World" :
		listnama.append(name)
		listleaderboard.append([listnama[z], listscore[z]])
		save_nama()
		menu_layer.UpdateLeaderboard(score, highscore, listscore, listnama, listleaderboard)
		save_listleaderboard()
		save_listscore()
		load_listscore()
		z = z + 1
		save_z()

func new_game():
	self.score = 0
	obstacle_spawner.start()
	
func player_score():
	self.score += 1

func set_score(new_score):
	score = new_score
	hud.update_score(score)

func _on_obstacle_created(obs):
	obs.connect("score", self, "player_score")

func _on_DeathZone_body_entered(body):
	if body is Player:
		if body.has_method("die"):
			body.die()

func _on_Player_died():
	listscore.append(score)
	save_listscore()
	load_listscore()
	#munculin popup input text
	var scene = preload("res://UIUX/leaderboard/inputnama.tscn").instance()
	scene.connect("get_name",self,"on_get_name")
	add_child(scene)
	game_over()

func game_over():
	obstacle_spawner.stop()
	ground.get_node("AnimationPlayer").stop()
	get_tree().call_group("obstacles", "set_physics_process", false)
	popup = true
		
	if score > highscore:
		highscore = score
		save_highscore()
	
	load_nama()
	load_listleaderboard()
	menu_layer.init_game_over_menu(score, highscore, listscore, listnama)

func _on_MenuLayer_start_game():
	new_game()

func save_highscore():
	var save_data = File.new()
	save_data.open(SAVE_FILE_PATH, File.WRITE)
	save_data.store_var(highscore)
	save_data.close()

func load_highscore():
	var save_data = File.new()
	if save_data.file_exists(SAVE_FILE_PATH):
		save_data.open(SAVE_FILE_PATH, File.READ)
		highscore = save_data.get_var()
		save_data.close()

func save_listscore():
	var save_data = File.new()
	save_data.open(SAVE_FILE_PATH2, File.WRITE)
	save_data.store_var(listscore)
	save_data.close()

func load_listscore():
	var save_data = File.new()
	if save_data.file_exists(SAVE_FILE_PATH2):
		save_data.open(SAVE_FILE_PATH2, File.READ)
		listscore = save_data.get_var()
		save_data.close()
	
func save_nama():
	var save_data = File.new()
	save_data.open(SAVE_FILE_PATH3, File.WRITE)
	save_data.store_var(listnama)
	save_data.close()

func load_nama():
	var save_data = File.new()
	if save_data.file_exists(SAVE_FILE_PATH3):
		save_data.open(SAVE_FILE_PATH3, File.READ)
		listnama = save_data.get_var()
		save_data.close()

func save_listleaderboard():
	var save_data = File.new()
	save_data.open(SAVE_FILE_PATH4, File.WRITE)
	save_data.store_var(listleaderboard)
	save_data.close()

func load_listleaderboard():
	var save_data = File.new()
	if save_data.file_exists(SAVE_FILE_PATH4):
		save_data.open(SAVE_FILE_PATH4, File.READ)
		listleaderboard = save_data.get_var()
		save_data.close()
		
func load_z():
	var save_data = File.new()
	if save_data.file_exists(SAVE_FILE_PATH4):
		save_data.open(SAVE_FILE_PATH5, File.READ)
		z = save_data.get_var()
		save_data.close()
		
func save_z():
	var save_data = File.new()
	save_data.open(SAVE_FILE_PATH5, File.WRITE)
	save_data.store_var(z)
	save_data.close()
