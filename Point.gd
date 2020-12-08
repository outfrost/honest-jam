class_name Point
extends Node2D

export var deg: int
export var links: Array

func _init() -> void:
	links = links.duplicate()

#func _init(pos: Vector2, deg: int) -> void:
#	self.pos = pos
#	self.deg = deg
#	links = []

#func _ready() -> void:
#	position

func linked_to(idx: int) -> bool:
	for link in links:
		if link.start == idx || link.end == idx:
			return true
	return false

func linkable() -> bool:
	return links.size() < deg
