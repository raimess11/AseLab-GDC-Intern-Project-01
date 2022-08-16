extends Node2D

onready var dialogText = $Anchor/Chat
onready var container = $Anchor/Chat/Container
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
	#cek dialog text ada atau tidak
	assert(dialogLine, "dialog not found.")
	#ambil line dialog, masukan ke property text di chat
	var textRaw = dialogLine[lineNum]["Chat"]
	dialogText.text = textRaw
	#atur margin/size container dan chat
	var xTextSize = containerLengthPerTextSize
	dialogText.margin_right = xTextSize
	#animation
	#fade in
	dialogText.visible_characters = 0
	tween.remove_all()
	tween.interpolate_property(anchor, "position", Vector2(0,2), Vector2(0,0), 0.2)
	tween.interpolate_property(container, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.2)
	tween.start()
	yield(tween,"tween_all_completed")
	#typewriter effect
	while dialogText.visible_characters < len(dialogText.text):
		dialogText.visible_characters += 1
		timer.start()
		yield(timer,"timeout")
	get_parent().isPlayingChat = false
	
	#jika player ingin skip animasi, maka fungsi ini berjalan
func skipSpeechBubble():
	tween.remove_all()
	tween.interpolate_property(anchor, "position", Vector2(0,2), Vector2(0,0), 0)
	tween.interpolate_property(container, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0)
	tween.start()
	dialogText.visible_characters = len(dialogText.text)



