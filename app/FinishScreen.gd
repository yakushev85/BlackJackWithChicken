extends Node2D


func _ready():
	if Global.game_data.chicken_eggs <= 0:
		$GenLabel.hide()
	else:
		$WinLabel.hide()
		var str_to_show = str($GenLabel.text)
		$GenLabel.text = str_to_show.replace("%", str(Global.game_data.player_eggs))



func _on_RestartButton_pressed():
	get_tree().change_scene("res://GameTable.tscn")
