extends Node2D

onready var dialogText = $Anchor/Chat
onready var container = $Anchor/Container
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
	dialogText.bbcode_text = textRaw
	#memisahkan dialog sebagai kumpulan line setiap containerLengthPerTextSize
	var textAfterWhile = ""
	var m = -1
	var yTextSize = dialogText.get_font("normal_font").get_string_size(dialogText.text).y
	var xTextSize = 0
	var textSizeInLoop = 0
	for x in range(0, len(textRaw)):
		textAfterWhile += dialogText.text[x]
		textSizeInLoop += dialogText.get_font("normal_font").get_string_size(dialogText.text[x]).x 
		if (int(textSizeInLoop) / containerLengthPerTextSize) > 0:
			if xTextSize < textSizeInLoop: xTextSize = textSizeInLoop
			textSizeInLoop -= containerLengthPerTextSize
			yTextSize += yTextSize
			while textAfterWhile[m] == ' ':
				textAfterWhile[m] = "\n"
				m += -1
	if yTextSize == dialogText.get_font("normal_font").get_string_size(dialogText.text).y:
		xTextSize = textSizeInLoop
	#atur margin/size container dan chat
	dialogText.bbcode_text = textAfterWhile
	dialogText.visible_characters = 0
	container.margin_top = -yTextSize - marginOffset
	dialogText.margin_top = -yTextSize - marginOffset
	
	container.margin_right = xTextSize + marginOffset
	dialogText.margin_right = xTextSize + marginOffset
	#animation
	tween.remove_all()
	tween.interpolate_property(anchor, "position", Vector2(0,2), Vector2(0,0), 0.2)
	tween.start()
	animationPlayer.play("containerFadeIn")
	yield(tween,"tween_all_completed")
	while dialogText.visible_characters < len(dialogText.text):
		dialogText.visible_characters += 1
		timer.start()
		yield(timer,"timeout")
	get_parent().isPlayingChat = false
	
	

func _input(event):
	if get_parent().isPlayingChat and Input.is_action_just_pressed("ui_accept"):
		tween.remove_all()
		tween.interpolate_property(anchor, "position", Vector2(0,2), Vector2(0,0), 0)
		tween.start()
		animationPlayer.seek(0.2, true)
		dialogText.visible_characters = len(dialogText.text)



