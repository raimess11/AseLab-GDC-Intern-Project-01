extends Area2D

export(int) var link_code: int = 0
signal switch_turned()

const TEXTURE: Dictionary = {
	'kiri' : preload("res://Object/switch/lever_turned_left.png"),
	'kanan' : preload("res://Object/switch/lever_turned_right.png")
}

var facing: int = 1

onready var actionables_container: Node2D = get_parent().get_node("actionables")
onready var sprite: Sprite = get_node("sprite")

func _ready()->void:
	if link_code != 0:
		for actionable in actionables_container.get_children():
			if actionable.link_code == link_code:
				connect("switch_turned",actionable,"_change_state")
