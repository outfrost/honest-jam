extends Node

#const CITY: PackedScene = preload("res://TestCity.scn")
const CITY: PackedScene = null

onready var map = $Map
var city: Node

func _ready() -> void:
	city = CITY.instance()
	city.set_script(null)
	map.add_child(city)
	call_deferred("stuff")

func stuff() -> void:
	var nodes = city.get_children()
	var edges = []
	for node in nodes:
		if node is Edge:
			edges.append(node)
	for edge in edges:
		edge.get_node(edge.start).links.append(edge)
		edge.get_node(edge.end).links.append(edge)
