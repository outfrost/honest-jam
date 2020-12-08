extends Node

const CITY: PackedScene = preload("res://City.tscn")

onready var map = $Map

func _ready() -> void:
	var city = CITY.instance()
	map.add_child(city)

