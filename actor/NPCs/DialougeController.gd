extends Node2D

export(String) var dialogPath
onready var speechBalloon = $SpeechBubble


var line: Array = []
var lineNum: int = 0
var lineSave = []

signal dialougeFinish

func _ready():
	speechBalloon.visible = false
	line = getDialog()


func getDialog() -> Array:
	var f = File.new()
	assert(f.file_exists(dialogPath), "File path does not exist")
	f.open(dialogPath, File.READ)
	var output = parse_json(f.get_as_text())
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []


var isPlaying = false setget set_isPlaying
var isPlayingChat = false setget set_isPlayingChat
var isPlayingTrigger = false setget set_isPlayingTrigger


#untuk tahu apakah dialouge main
func set_isPlaying(value):
	isPlaying = value
	if not isPlaying:
		emit_signal("dialougeFinish")
	
func set_isPlayingChat(value):
	isPlayingChat = value
	if isPlayingChat:
		self.isPlaying = true
	if !isPlayingChat and !isPlayingTrigger:
		self.isPlaying = false
	
func set_isPlayingTrigger(value):
	isPlayingTrigger = value
	if isPlayingTrigger:
		self.isPlaying = true
	if !isPlayingChat and !isPlayingTrigger:
		self.isPlaying = false

func dialougeProcess():
	visible = true
	if lineNum < len(line):
		get_parent().get_node("QuestionMark").visible = false
		if "Chat" in line[lineNum]:
			chatProcess()
		else:
			speechBalloon.visible = false
		if "Trigger" in line[lineNum]:
			triggerProcess()
		
		yield(self,"dialougeFinish")
		print(2)
		lineNum += 1
	else:
		get_parent().get_node("QuestionMark").visible = true
		lineNum = 0
		speechBalloon.visible = false
		get_node("ForTrigger").play("RESET")
	if get_parent().bodyExit:
		lineNum = 0
func chatProcess():
	speechBalloon.visible = true
	speechBalloon.position.y = -40
	self.isPlayingChat = true
	speechBalloon.showLine(line, lineNum)
	
func triggerProcess():
	self.isPlayingTrigger = true
	get_node("ForTrigger").play(line[lineNum]["Trigger"])
	yield(get_node("ForTrigger"),"animation_finished")
	self.isPlayingTrigger = false


func _on_InputController_input_proceed():
	if isPlaying:
		yield(self,"dialougeFinish")
	elif get_parent().active:
		dialougeProcess()
