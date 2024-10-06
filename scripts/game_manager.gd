extends Node

var score = 0
var lives = 5
var day_cycle = 0.0
var dayTime = 0
@onready var score_label: Label = $ScoreLabel
#@onready var felicitaciones_label: Label = $FelicitacionesLabel

func _process(delta: float) -> void:
	day_cycle += delta
	if day_cycle > 12:
		day_cycle = 0.0

func add_point():
	score += 1
	#if(score == 4):
		#felicitaciones_label.text = "¡¡Felicitaciones!!"
	var moneda_text = " moneda!"
	if(score > 1):
		moneda_text = " monedas!"
	#score_label.text = "¡Juntaste " + str(score) + moneda_text
