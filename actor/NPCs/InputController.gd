extends Node2D


signal input_proceed


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("input_proceed")
