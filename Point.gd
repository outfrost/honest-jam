class_name Point
extends Node2D

export var deg: int
export var links: Array

func _init() -> void:
	links = links.duplicate()

func linked_to(idx: int) -> bool:
	for link in links:
		if link.start == idx || link.end == idx:
			return true
	return false

func linkable() -> bool:
	return links.size() < deg
