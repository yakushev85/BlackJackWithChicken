extends Node2D


func _ready():
	$WelcomeAudioStreamPlayer.play()


func _on_StartButton_pressed():
	get_tree().change_scene("res://GameTable.tscn")
