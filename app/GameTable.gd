extends Node2D


func _ready():
	$ChickenCardHolder/Card.generate_r()
	$ChickenCardHolder/Card.set_bstatus(true)
	
	$PlayerCardHolder/Card2.generate_r()
	$PlayerCardHolder/Card2.set_bstatus(false)

