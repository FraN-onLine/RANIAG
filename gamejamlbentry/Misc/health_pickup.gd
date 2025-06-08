extends Area2D

@export var health_amount: int = 25

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.has_method("add_health"):
		body.add_health(health_amount)
		queue_free()
