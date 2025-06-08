# minimap.gd
extends MarginContainer
@export var player: NodePath
@export var zoom = 6
@onready var grid: TextureRect = $MarginContainer/Grid
@onready var player_marker: AnimatedSprite2D = $MarginContainer/Grid/Player
@onready var enemy: Sprite2D = $MarginContainer/Grid/Enemy
@onready var alert: Sprite2D = $MarginContainer/Grid/Alert
@onready var icons = {"mob": enemy, "alert": alert}
var grid_scale
var markers = {}

func _ready() -> void:
	player_marker.position = grid.size / 2
	grid_scale = grid.size * zoom / get_viewport().get_visible_rect().size
	var minimap_objects = get_tree().get_nodes_in_group("minimap_objects")
	for item in minimap_objects:
		if item.has_method("get") and item.get("minimap_icon") in icons:
			var new_marker = icons[item.minimap_icon].duplicate()
			grid.add_child(new_marker)
			new_marker.show()
			markers[item] = new_marker

func _process(delta: float) -> void:
	if !player:
		return
	var player_node = get_node(player)
	if !player_node:
		return
	
	player_marker.position = grid.size / 2
		
	for item in markers:
		var relative_pos = item.position - player_node.position
		# Flip both axes to correct horizontal and vertical flipping
		relative_pos.x = -relative_pos.x
		relative_pos.y = -relative_pos.y
		var obj_pos = relative_pos * grid_scale + grid.size / 2
		obj_pos.x = clamp(obj_pos.x, 0, grid.size.x)
		obj_pos.y = clamp(obj_pos.y, 0, grid.size.y)
		markers[item].position = obj_pos
