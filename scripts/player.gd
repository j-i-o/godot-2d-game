extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0
enum estados {OK, HIT, HURT, DEAD, FLY, JUMP}
enum skills {FLY, HIGHJUMP}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var jump_timer: Timer = $JumpTimer
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var feather_sound: AudioStreamPlayer2D = $FeatherSound
@onready var jump_animation_timer: Timer = $JumpAnimationTimer

var blockedInput
var immunity = false
var health = 100
var status = estados.OK
var jumping = false
var skill = []

func _ready() -> void:
	SignalBus.on_hit.connect(_on_hit)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumping = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and skill.has(skills.HIGHJUMP):
		#Empiezo a cargar el salto
		jump_animation_timer.start()
		jump_timer.start()
	if Input.is_action_just_released("jump"):
		jump()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		if status == estados.FLY:
			animation_player.play("flying")
		elif status != estados.HURT:
			animated_sprite.play("jump")
	
	if status == estados.HIT:
		velocity = knockback(delta)
		status = estados.HURT
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func _on_timer_timeout() -> void:
	status = estados.OK
	animation_player.stop()
	
func _on_hit(damage) -> void:
	if(status == estados.OK):
		animation_player.play("hurt")
		status = estados.HIT
		health -= damage
		print(health)
		timer.start()

func knockback (delta: float) -> Vector2:
	status = estados.HURT
	var val = -1 if velocity.x > 0 else 1
	velocity.x = 35000 * delta * val
	velocity.y = -10000 * delta
	return velocity
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "flying" and !is_on_floor()) or anim_name == "hurt":
		status = estados.OK

func jump() -> void:
	jumping = true
	var charge = 1
	if animation_player.current_animation == "chargingJump":
		charge = 1.3
	elif animation_player.current_animation == "chargedJump":
		charge = 1.5
	if animation_player.current_animation == "chargingJump" or animation_player.current_animation == "chargedJump":
		animation_player.stop()
	
	if is_on_floor():
		jump_sound.play()
		velocity.y = JUMP_VELOCITY * charge
	elif status != estados.FLY and skill.has(skills.FLY):
		status = estados.FLY
		velocity.y = JUMP_VELOCITY

func _on_jump_timer_timeout() -> void:
	if !jumping and Input.is_action_pressed("jump"): 
		animation_player.play("chargedJump")
	
func _on_jump_animation_timer_timeout() -> void:
	if !jumping and Input.is_action_pressed("jump"):
		animation_player.play("chargingJump")

func addSkill(skillNuevo) -> void:
	match skillNuevo:
		"fly":
			skill.append(skills.FLY)
		"jump":
			skill.append(skills.HIGHJUMP)
