extends KinematicBody2D

onready var interaction = $Interaction
onready var questionMark = $QuestionMark
onready var dialougeController = $DialougeController

var active = false setget set_active
var questionMarkActive = false setget set_questionMarkActive

#untuk menunjukan question mark. Bila berapa di dalam collision interaction, maka question mark active

func set_questionMarkActive(value):
	questionMarkActive = value
	questionMark.visible = value

func set_active(value):
	active = value
	self.questionMarkActive = value


func _on_Interaction_body_entered(body):
	if body.name == "Player":
		self.active = true


func _on_Interaction_body_exited(body):
	if body.name == "Player":
		self.active = false

