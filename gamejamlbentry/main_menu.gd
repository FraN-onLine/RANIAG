extends Control
@onready var buttons: VBoxContainer = $Buttons
@onready var options: Panel = $Options

func _ready():
	buttons.visible = true;
	options.visible = false;

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_options_pressed() -> void:
	buttons.visible = false;
	options.visible = true;

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	_ready();
