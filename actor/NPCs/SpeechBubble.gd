extends Node2D

onready var dialogText = $Anchor/Chat
onready var timer = $Timer
onready var tween = $Tween
onready var anchor = $Anchor
onready var animationPlayer = $AnimationPlayer

export var marginOffset = 16
export var dialogPath: String = ""
export(float) var textSpeed = 0.1
export(int) var containerLengthPerTextSize = 150


var dialogLine

func showLine(dialogLine, lineNum):
	#set delay per text
	timer.wait_time = textSpeed
	assert(dialogLine, "dialog not found.")
	#backend stuff and sizing
	var textRaw = dialogLine[lineNum]["Chat"]
	dialogText.text = textRaw
	#atur margin/size container dan chat
	
	var xTextSize = containerLengthPerTextSize
	dialogText.margin_right = xTextSize
	#animation
	dialogText.visible_characters = 0
	animationPlayer.seek(0,true)
	animationPlayer.play("containerEnter")
	timer.start(animationPlayer.current_animation_length)
	
	yield(timer,"timeout")
	var animationTypeWrite = Animation.new()
	animationPlayer.add_animation("typeWrite", animationTypeWrite)
	var i = animationTypeWrite.add_track(Animation.TYPE_VALUE)
	animationTypeWrite.track_set_path(i,"Anchor/Chat:visible_characters")
	var floatn = 0.0
	for n in range(0, len(dialogText.text)):
		floatn = n/10.0
		animationTypeWrite.track_insert_key(i,floatn,n)
	animationPlayer.get_animation("typeWrite").length = (animationPlayer.get_animation("typeWrite").track_get_key_count(i)/10) + 0.01
	animationPlayer.play("typeWrite")
	yield(animationPlayer, "animation_finished")
	get_parent().isPlayingChat = false
	skipDialouge = false
	
	

func _input(event):
	if get_parent().isPlayingChat and Input.is_action_just_pressed("ui_accept"):
		skipDialouge()
		
var skipDialouge = false
func skipDialouge():
	animationPlayer.advance(len(dialogText.text))
	skipDialouge = true
	
func skipDialougeDueToExited():
	animationPlayer.advance(len(dialogText.text))
	skipDialouge = true
	get_parent().lineNum = -1



