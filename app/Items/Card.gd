extends Node2D

var RED_COLOR = Color("ff0000")
var BLACK_COLOR = Color("000000")

func _ready():
	set_bstatus(true)


func set_card(preval, sym):
	$Labels/BottomCardDigitLabel.text = preval
	$Labels/TopCardDigitLabel.text = preval
	
	$Labels/BottomCardSymLabel.text = sym
	$Labels/TopCardSymLabel.text = sym
	$Labels/CenterCardSymLabel.text = sym
	
	if sym in ["1", "2"]:
		$Labels/BottomCardDigitLabel.add_color_override("font_color", RED_COLOR)
		$Labels/TopCardDigitLabel.add_color_override("font_color", RED_COLOR)
		$Labels/BottomCardSymLabel.add_color_override("font_color", RED_COLOR)
		$Labels/TopCardSymLabel.add_color_override("font_color", RED_COLOR)
		$Labels/CenterCardSymLabel.add_color_override("font_color", RED_COLOR)
	else:
		$Labels/BottomCardDigitLabel.add_color_override("font_color", BLACK_COLOR)
		$Labels/TopCardDigitLabel.add_color_override("font_color", BLACK_COLOR)
		$Labels/BottomCardSymLabel.add_color_override("font_color", BLACK_COLOR)
		$Labels/TopCardSymLabel.add_color_override("font_color", BLACK_COLOR)
		$Labels/CenterCardSymLabel.add_color_override("font_color", BLACK_COLOR)


func set_bstatus(is_back):
	if is_back:
		$Labels.visible = false
		$BackCard.visible = true
	else:
		$Labels.visible = true
		$BackCard.visible = false
		
			
func get_preval():
	return $Labels/TopCardDigitLabel.text


func get_sym():
	return $Labels/CenterCardSymLabel.text
	
	
func get_cardid():
	return get_preval() + ":" + get_sym()


func set_cardid(cardid):
	var rawStrArray = str(cardid).split(":")
	set_card(rawStrArray[0], rawStrArray[1])
	
func get_card_val():
	var pval = get_preval()
	if pval in ["J", "Q", "K"]:
		return 10
	elif pval == "A":
		return 11
	else:
		return int(pval)
