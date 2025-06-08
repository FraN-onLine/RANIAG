extends Node2D

@onready var area2d: Area2D = $Area2D
@onready var explosion_anim: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var default_sprite: Sprite2D = $Area2D/Sprite2D

var is_destroyed = false

func _ready():
	# Connect body_entered signal to detect collisions
	area2d.body_entered.connect(_on_body_entered)
	explosion_anim.visible = false  # Initially hide explosion animation

func _on_body_entered(body: PhysicsBody2D):
	# Check if the body is the weapon hitbox and crate is not destroyed
	if body.is_in_group("weapon_hitbox") and not is_destroyed:
		is_destroyed = true
		default_sprite.visible = false  # Hide the crate's default sprite
		explosion_anim.visible = true  # Show explosion animation
		explosion_anim.play("explode")  # Play the explosion animation
		explosion_anim.animation_finished.connect(_on_explosion_finished)

func _on_explosion_finished():
	queue_free()  # Remove crate from the scene after explosion animation finishes
