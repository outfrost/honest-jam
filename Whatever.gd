extends Node2D

class Point:
	var pos: Vector2
	var links: Array
	var deg: int

	func _init(pos: Vector2, deg: int) -> void:
		self.pos = pos
		self.deg = deg
		links = []

	func linked_to(idx: int) -> bool:
		for link in links:
			if link.start == idx || link.end == idx:
				return true
		return false

	func linkable() -> bool:
		return links.size() < deg

const WIDTH: float = 1920.0
const HEIGHT: float = 1400.0
const PIN: PackedScene = preload("res://Pin.tscn")
const EDGE: PackedScene = preload("res://Edge.tscn")
const NUM_POINTS: int = 4096
const NUM_CLOSEST: int = 10
const MIN_DEG: int = 2
const MAX_DEG: int = 5

var rng = RandomNumberGenerator.new()

var points = []

func _ready() -> void:
	rng.randomize()
	var rect = Rect2(Vector2(- 0.5 * WIDTH, -0.5 * HEIGHT), Vector2(WIDTH, HEIGHT))
	for i in range(NUM_POINTS):
#		var pos = Vector2(
#			(rng.randfn(0.0, 1.4) * WIDTH * 0.15),
#			(rng.randfn(0.0, 1.4) * HEIGHT * 0.15)
#		)
#		if !rect.has_point(pos):
#			pos *= 0.6
		var pos = Vector2(
			(rng.randf() * 2.0 - 1.0),
			(rng.randf() * 2.0 - 1.0)
		)
		var exp1 = exp(1.0) - 1.0
		pos.x *= ((exp(clamp(pos.length(), 0.0, 1.0)) - 1.0) / exp1) / pos.x
		pos.y *= ((exp(clamp(pos.length(), 0.0, 1.0)) - 1.0) / exp1) / pos.y
#		pos.x *= pow(abs(pos.x), 0.8)
#		pos.y *= pow(abs(pos.y), 0.8)
		pos *= Vector2(WIDTH, HEIGHT) * 0.5
		pos.x = clamp(pos.x, - 0.5 * WIDTH, 0.5 * WIDTH)
		pos.y = clamp(pos.y, - 0.5 * HEIGHT, 0.5 * HEIGHT)
		points.append(Point.new(pos, rng.randi_range(MIN_DEG, MAX_DEG)))
		var pin = PIN.instance()
		pin.position = pos
		add_child(pin)
		pin.owner = self
	for idx in range(points.size()):
		var point = points[idx]
		var others = closest(idx)
#		var i = point.links.size()
#		while i < point.deg:
#			for k in range(others.size()):
#				var other_idx = others[rng.randi_range(0, others.size() - 1)]
#				var other = points[other_idx]
#				if (
#					!point.linked_to(other_idx)
#					&& other.linkable()
#				):
#					var edge = EDGE.instance()
#					edge.start = idx
#					edge.end = other_idx
#					edge.update_line(self)
#					add_child(edge)
#					edge.owner = self
#					point.links.append(edge)
#					other.links.append(edge)
#					break
#			i += 1
		var i = 0
		while point.linkable() && i < others.size():
			var other_idx = others[i]
			var other = points[other_idx]
			if (
				!point.linked_to(other_idx)
				&& other.linkable()
			):
				var edge = EDGE.instance()
				edge.start = idx
				edge.end = other_idx
				edge.update_line(self)
				add_child(edge)
				edge.owner = self
				point.links.append(edge)
				other.links.append(edge)
			i += 1
	call_deferred("save")

func save() -> void:
	var scn = PackedScene.new()
	scn.pack(self)
	ResourceSaver.save("res://City.tscn", scn)

func closest(idx: int) -> Array:
	var pos: Vector2 = points[idx].pos
	var others = []

	for i in range(points.size()):
		if i == idx:
			continue
		var other = points[i]
		others.append({ idx = i, dist = pos.distance_to(other.pos) })

	others.sort_custom(self, "by_distance")

	var closest = []
	var i = 0
	while i < others.size() && i < NUM_CLOSEST:
		closest.append(others[i].idx)
		i += 1
	return closest

static func by_distance(a, b):
	return a.dist < b.dist
