extends Node2D

class Point:
	var pos: Vector2
	var links: Array

	func _init(pos: Vector2) -> void:
		self.pos = pos
		links = []

	func linked_to(idx: int) -> bool:
		return false

const WIDTH: float = 1920.0
const HEIGHT: float = 1080.0
const PIN: PackedScene = preload("res://Pin.tscn")
const EDGE: PackedScene = preload("res://Edge.tscn")
const NUM_POINTS: int = 512
const MIN_DEG: int = 2
const MAX_DEG: int = 5

var rng = RandomNumberGenerator.new()

var points = []

func _ready() -> void:
	rng.randomize()
	for i in range(NUM_POINTS):
		var pos = Vector2(
			(rng.randfn() * WIDTH * 0.15),
			(rng.randfn() * HEIGHT * 0.15)
		)
		points.append(Point.new(pos))
		var pin = PIN.instance()
		pin.position = pos
		add_child(pin)
	for idx in range(points.size()):
		var point = points[idx]
		var deg = rng.randi_range(MIN_DEG, MAX_DEG)
		var others = closest(idx)
		var i = 0
		while point.links.size() < deg && i < others.size():
			var other_idx = others[i]
			var other = points[other_idx]
			if (
				!point.linked_to(other_idx)
				&& other.links.size() < MAX_DEG
			):
				var edge = EDGE.instance()
				edge.start = idx
				edge.end = other_idx
				edge.update_line(self)
				add_child(edge)
				point.links.append(edge)
				other.links.append(edge)
			i += 1

func closest(idx: int) -> Array:
	var pos: Vector2 = points[idx].pos
	var others = []
	for i in range(points.size()):
		if i == idx:
			continue
		var other = points[i]
		var dist = pos.distance_to(other.pos)
		var k = 0
		while k < others.size():
			if others[k].dist > dist:
				break
			k += 1
		others.insert(k, { idx = i, dist = dist })
	var closest = []
	var i = 0
	while i < others.size() && i < 10:
		closest.append(others[i].idx)
		i += 1
	return closest
