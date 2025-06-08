extends CharacterBody2D

class_name Player

signal healthChanged

@onready var healthbar: ProgressBar = $Healthbar
@onready var weapon_hitbox: Area2D = $Hand/Node2D/Sprite2D/weaponHitbox
@export var base_speed: float = 200.0
@export var base_attack: int = 12.5
@export var camera: Camera2D

var speed: float = base_speed
var attack_damage: int = base_attack

var is_speed_buffed: bool = false
var is_attack_buffed: bool = false

var max_health = 100
var health = 100
var attacking = false
var is_dead = false
var stage = 1
var death_position: Vector2

var multiplier = 1
var is_dashing = false
var dash_speed = 500.0
var dash_time = 0.18
var dash_timer = 0.0
var dash_direction = Vector2.ZERO

func _ready():
	health = max_health
	is_dead = false
	GameState.player_alive = true
	speed = base_speed
	attack_damage = base_attack

	if is_instance_valid(healthbar):
		healthbar.init_health(max_health)

	if is_instance_valid(weapon_hitbox):
		weapon_hitbox.monitoring = false
	else:
		print("Weapon hitbox not found! Check node path.")

func _process(delta):
	$Hand/Node2D/Sprite2D/weaponHitbox._set_damage(base_attack * multiplier)
	if is_dead:
		return  # Prevent input/movement when dead

	if is_dashing:
		var collision = move_and_collide(dash_direction * dash_speed * delta)
		if collision:
			is_dashing = false
			if is_instance_valid(weapon_hitbox):
				weapon_hitbox.monitoring = false
		else:
			dash_timer -= delta
			if dash_timer <= 0:
				is_dashing = false
				if is_instance_valid(weapon_hitbox):
					weapon_hitbox.monitoring = false
		return # Skip normal movement while dashing

	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	input_vector = input_vector.normalized() * speed if input_vector.length() > 0 else Vector2.ZERO
	velocity = input_vector
	move_and_slide()

	if input_vector.x != 0:
		$AnimatedSprite2D.flip_h = input_vector.x < 0

	# Aim hand towards mouse
	var arrow = $Hand
	if arrow:
		var mouse_pos = get_global_mouse_position()
		var angle = (mouse_pos - global_position).angle()
		arrow.rotation = angle
		arrow.position = Vector2.RIGHT.rotated(angle) * 3.5

	if camera:
		camera.position = position

func _input(event):
	if is_dead:
		return

	if event.is_action_pressed("basic_attack") and not is_dashing:
		var mouse_pos = get_global_mouse_position()
		var dash_vec = (mouse_pos - global_position)
		if dash_vec.length() > 0:
			is_dashing = true
			dash_timer = dash_time
			dash_direction = dash_vec.normalized()
			$AnimatedSprite2D.play("dash") # If you have a dash animation
			# Flip sprite to dash direction
			$AnimatedSprite2D.flip_h = dash_direction.x < 0
			if is_instance_valid(weapon_hitbox):
				weapon_hitbox.monitoring = true
	elif event.is_action_released("basic_attack"):
		attacking = false
		if is_instance_valid(weapon_hitbox):
			weapon_hitbox.monitoring = false

func set_damage(amount = attack_damage):
	if is_instance_valid(weapon_hitbox):
		weapon_hitbox.damage = amount

func take_damage(damage):
	if is_dead:
		return

	health -= damage

	if is_instance_valid(healthbar):
		healthbar._set_health(health)

	emit_signal("healthChanged", health)

	if health <= 0:
		health = 0
		is_dead = true
		GameState.player_alive = false
		death_position = position

		$AnimatedSprite2D.visible = false
		if is_instance_valid(healthbar):
			healthbar.hide()

		if is_instance_valid(weapon_hitbox):
			weapon_hitbox.monitoring = false

		print("Unit is dead!")
		stage += 1
		max_health -= 10
		multiplier += 0.1
		if is_instance_valid(healthbar):
			healthbar.init_health(max_health)

		await get_tree().create_timer(5.0).timeout

		if stage <= 5:
			respawn()
		else:
			get_tree().change_scene_to_file("res://Scenes/YouDIEDMOTHERFUCKA.tscn")

func add_health(amount: int):
	if is_dead:
		return

	health = min(health + amount, max_health)

	if is_instance_valid(healthbar):
		healthbar._set_health(health)

	emit_signal("healthChanged", health)

func respawn():
	position = death_position
	health = max_health
	is_dead = false
	GameState.player_alive = true

	if is_instance_valid(healthbar):
		healthbar.show()
		healthbar._set_health(health)

	$AnimatedSprite2D.visible = true
	emit_signal("healthChanged", health)

# -------------------------------
# Buff Functions (TEMPORARY)
# -------------------------------
func apply_speed_buff(multiplier: float, duration: float):
	if is_speed_buffed:
		return
	is_speed_buffed = true
	speed *= multiplier
	print("Speed buff applied! New speed:", speed)

	await get_tree().create_timer(duration).timeout
	speed = base_speed
	is_speed_buffed = false
	print("Speed buff ended. Speed reset to:", speed)

func apply_attack_buff(multiplier: float, duration: float):
	if is_attack_buffed:
		return
	is_attack_buffed = true
	attack_damage *= multiplier
	print("Attack buff applied! New damage:", attack_damage)

	await get_tree().create_timer(duration).timeout
	attack_damage = base_attack
	is_attack_buffed = false
	print("Attack buff ended. Damage reset to:", attack_damage)
