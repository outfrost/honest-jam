class_name Point
extends Node2D

export var deg: int

var links: Array

func _init() -> void:
	links = links.duplicate()

func linked_to(other: Point) -> bool:
	var path = get_path_to(other)
	for link in links:
		if link.start == path || link.end == path:
			return true
	return false

func linkable() -> bool:
	return links.size() < deg
