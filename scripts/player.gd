extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0
enum estados {OK, HIT, HURT, DEAD, FLY, JUMP}
enum skills {FLY, HIGHJUMP}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtTimer: Timer = $HurtTimer
@onready var jump_sound: AudioStreamPlayer2D = $Sounds/JumpSound
@onready var feather_sound: AudioStreamPlayer2D = $Sounds/FeatherSound
@onready var hurt_sound: AudioStreamPlayer2D = $Sounds/HurtSound

var blockedInput
var immunity = false
var health = 100
var status = estados.OK
var jumping = false
var skill = []
var jumpTimer = 0.0

func _ready() -> void:
	SignalBus.on_hit.connect(_on_hit)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumping = false

	#if Input.is_action_just_pressed("special"):
		
	# Handle jump.
	if skill.has(skills.HIGHJUMP):
		if Input.is_action_pressed("move_down") and !jumping:
			jumpTimer += delta
			if jumpTimer < 4.0 and jumpTimer > 1.5:
				setShaderParameter("enabled", 1)
				if hurtTimer.is_stopped():
					setShaderParameter("shine_color", Vector4(1.0, 1.0, 1.0, 1.0))
				setShaderParameter("cycle_speed", 6)
			elif jumpTimer > 4.0:
				setShaderParameter("cycle_speed", 10)
		elif Input.is_action_just_released("move_down"):
			highJump()
	if Input.is_action_just_pressed("jump"):
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
		status = estados.OK
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func _on_hit(damage) -> void:
	if(status == estados.OK):
		hurt_sound.play()
		status = estados.HIT
		health -= damage
		print(health)
		hurtTimer.start()
		setShaderParameter("enabled", 1.0)
		setShaderParameter("shine_color", Vector4(1.0, 0.0, 0.0, 1.0))
		setShaderParameter("cycle_speed", 9.0)

func knockback (delta: float) -> Vector2:
	status = estados.HURT
	var val = -1 if velocity.x > 0 else 1
	velocity.x = 35000 * delta * val
	velocity.y = -10000 * delta
	return velocity
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "flying" and !is_on_floor()) or anim_name == "hurt":
		status = estados.OK

func highJump() -> void:
	print(jumpTimer)
	setShaderParameter("enabled", 0.0)
	var charge = 1
	jumping = true
	
	if jumpTimer < 4.0 and jumpTimer >= 1.5:
		print("salto medio")
		charge = 1.3
	elif jumpTimer >= 4.0:
		print("salto alto")
		charge = 1.5
	else:
		print("salto comun")
	velocity.y = JUMP_VELOCITY * charge
	jumpTimer = 0

func jump() -> void:
	if is_on_floor():
		jump_sound.play()
		velocity.y = JUMP_VELOCITY
	elif status != estados.FLY and skill.has(skills.FLY):
		status = estados.FLY
		velocity.y = JUMP_VELOCITY

func addSkill(skillNuevo) -> void:
	match skillNuevo:
		"fly":
			skill.append(skills.FLY)
		"jump":
			skill.append(skills.HIGHJUMP)

func setShaderParameter(parameter, value) -> void:
	animated_sprite.material.set_shader_parameter(parameter, value)

func _on_hurt_timer_timeout() -> void:
	setShaderParameter("enabled", 0.0)
