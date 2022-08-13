extends KinematicBody2D

onready var interaction = $Interaction
onready var questionMark = $QuestionMark
onready var dialougeController = $DialougeController
onready var animationPlayer = $AnimationPlayer

var active = false setget set_active
var questionMarkActive = false setget set_questionMarkActive
var x := 0

export var interaction_texture : Texture = preload("res://.import/icons8-hand-16.png-5391f4ae3a28ef0836f46a95bc5d0d53.stex")

#untuk menunjukan question mark. Bila berapa di dalam collision interaction, maka question mark active

func _ready():
	$Sprite.frame = 0
	animationPlayer.play("Idle")

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

#load texture
func interaction_get_texture() -> Texture:
	return interaction_texture

#ngasi tau node ini bisa interaksi
func interaction_can_speak(interactionComponentParent : Node) -> bool :
	return interactionComponentParent is Player

#UI text yang mau dimunculin kalo masuk radius interaksi
func interaction_get_text() -> String:
	return "E to Speak"

#yang dilakuin pas interaksi
func interaction_interact(interactionComponentParent : Node) -> void :
	print("SPEAK SUCCESS")
	x += 1
	print(x)
