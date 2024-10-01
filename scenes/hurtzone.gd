extends Area2D

signal damaged

func _on_body_entered(body: Node2D) -> void:
	damaged.emit()

func damage():
	pass
	#lives -= 1
	#if(lives == 0):
		#Engine.time_scale = 1
		#get_tree().reload_current_scene()
	#else:
		#empujar player
