extends Node2D


const SPEED = 30
@export var damage = 2

var direction = 1

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_down_right: RayCast2D = $RayCastDownRight
@onready var ray_cast_down_left: RayCast2D = $RayCastDownLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !ray_cast_down_right.is_colliding() or !ray_cast_down_left.is_colliding() or ray_cast_right.is_colliding() or ray_cast_left.is_colliding():
		direction = direction * -1
		animated_sprite.flip_h = !animated_sprite.flip_h

	position.x += direction * SPEED * delta

func _on_hurtzone_body_entered(body: Node2D) -> void:
	SignalBus.on_hit.emit(damage)
