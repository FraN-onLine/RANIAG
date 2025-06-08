extends Area2D

@export var multiplier := 1.5
@export var duration := 5.0

func _on_body_entered(body):
	if body is Player:
		body.apply_speed_buff(multiplier, duration)
		queue_free()  # remove the pickup after use

func _ready():
	connect("body_entered", _on_body_entered)
