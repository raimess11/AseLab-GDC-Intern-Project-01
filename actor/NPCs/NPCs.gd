extends KinematicBody2D

onready var interaction = $Interaction
onready var questionMark = $QuestionMark
onready var dialougeController = $DialougeController

var active = false setget set_active
var bodyExit = false
#untuk menunjukan question mark. Bila berapa di dalam collision interaction, maka question mark active

func set_active(value):
	active = value
	questionMark.visible = value
 

func _on_Interaction_body_entered(body):
	var bodyExit = false
	if body.name == "Player":
		self.active = true


func _on_Interaction_body_exited(body):
	if $DialougeController/SpeechBubble/AnimationPlayer.is_playing():
		$DialougeController/SpeechBubble.skipDialougeDueToExited()
	$DialougeController/ForTrigger.play("RESET")
	if body.name == "Player":
		self.active = false
	dialougeController.visible = false
	dialougeController.lineNum = 0

