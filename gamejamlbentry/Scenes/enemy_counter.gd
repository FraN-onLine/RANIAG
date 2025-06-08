extends Label

func _process(delta: float) -> void:
	$".".text = "Enemies: " + str(Global.EnemiesToBeat)
