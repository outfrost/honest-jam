extends Node2D

const WIDTH: float = 1920.0
const HEIGHT: float = 1400.0
const POINT: PackedScene = preload("res://Point.tscn")
const EDGE: PackedScene = preload("res://Edge.tscn")
const NUM_POINTS: int = 4096
const NUM_CLOSEST: int = 10
const MIN_DEG: int = 3
const MAX_DEG: int = 4

var rng = RandomNumberGenerator.new()

var points = []

func _ready() -> void:
	rng.randomize()
	var rect = Rect2(Vector2(- 0.5 * WIDTH, -0.5 * HEIGHT), Vector2(WIDTH, HEIGHT))
	for i in range(NUM_POINTS):
		var angle = rng.randf_range(0.0, TAU)
		var mag = sqrt(rng.randf())

		var pos = Vector2(
			mag * cos(angle),
			mag * sin(angle)
		)
		pos *= Vector2(WIDTH, HEIGHT) * 0.5

		if i >= NUM_POINTS * 15 / 16: # 0.9375
			pos *= 0.25
		elif i >= NUM_POINTS * 8 / 10: # 0.8
			pos *= 0.45
		elif i >= NUM_POINTS * 8 / 16: # 0.5
			pos *= 0.7
		elif i < NUM_POINTS * 2 / 10: # 0.2
			pos = Vector2(
				rng.randf_range(rect.position.x, rect.end.x),
				rng.randf_range(rect.position.y, rect.end.y)
			)

		pos = clamped_to_rect(pos, rect)

		var point = POINT.instance()
		point.position = pos
		point.deg = rng.randi_range(MIN_DEG, MAX_DEG)
		add_child(point)
		point.owner = self
		points.append(point)

	print("%d points generated" % points.size())

	for idx in range(points.size()):
		var point = points[idx]
		var others = closest(idx)
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
	var pos: Vector2 = points[idx].position
	var others = []

	for i in range(points.size()):
		if i == idx:
			continue
		var other = points[i]
		others.append({ idx = i, dist = pos.distance_to(other.position) })

	others.sort_custom(self, "by_distance")

	var closest = []
	var i = 0
	while i < others.size() && i < NUM_CLOSEST:
		closest.append(others[i].idx)
		i += 1
	return closest

static func by_distance(a, b):
	return a.dist < b.dist

static func clamped_to_rect(v: Vector2, r: Rect2) -> Vector2:
	return Vector2(
		clamp(v.x, r.position.x, r.end.x),
		clamp(v.y, r.position.y, r.end.y)
	)
