extends Node2D

const WIDTH: float = 1920.0
const HEIGHT: float = 1400.0
const POINT: PackedScene = preload("res://Point.tscn")
const EDGE: PackedScene = preload("res://Edge.tscn")
const NUM_POINTS: int = 1536
const NUM_CLOSEST: int = 10
const MIN_DEG: int = 3
const MAX_DEG: int = 4
const MIN_DIST_SQUARED: float = 16.0 * 16.0
const RECT: Rect2 = Rect2(Vector2(- 0.5 * WIDTH, -0.5 * HEIGHT), Vector2(WIDTH, HEIGHT))
const ITER_IN_PROCESS: int = 4

var rng = RandomNumberGenerator.new()

var points = []
var idx = 0

func _ready() -> void:
	rng.randomize()
	for i in range(NUM_POINTS):
		var pos = gen_pos(i)

		var attempt = 0
		var too_close = too_close(pos)
		while attempt < 8 && too_close:
			pos = gen_pos(i)
			too_close = too_close(pos)
			attempt += 1
		if too_close:
			continue

		var point = POINT.instance()
		point.position = pos
		point.deg = rng.randi_range(MIN_DEG, MAX_DEG)
		add_child(point)
		point.owner = self
		points.append(point)

	print("%d points generated" % points.size())

func _process(delta: float) -> void:
	var k = 0
	while k < ITER_IN_PROCESS && idx < points.size():
		var point = points[idx]
		var others = closest(idx)

		if others.size() >= 2:
			var tmp = others[0]
			others[0] = others[1]
			others[1] = tmp
		
		var i = 0
		while point.linkable() && i < others.size():
			var other = points[others[i]]
			if (
				!point.linked_to(other)
				&& other.linkable()
			):
				var exceptions = []
				for edge in point.links:
					exceptions.append(edge.get_child(0))
				for edge in other.links:
					exceptions.append(edge.get_child(0))

				var space_state = get_world_2d().direct_space_state
				var result = space_state.intersect_ray(
					point.position,
					other.position,
					exceptions
				)

				if result.empty():
					var edge = EDGE.instance()
					add_child(edge)
					edge.owner = self
					edge.start = edge.get_path_to(point)
					edge.end = edge.get_path_to(other)
					edge.update_line()
					point.links.append(edge)
					other.links.append(edge)
					var body = StaticBody2D.new()
					var collision = CollisionShape2D.new()
					collision.shape = SegmentShape2D.new()
					(collision.shape as SegmentShape2D).a = point.position
					(collision.shape as SegmentShape2D).b = other.position
					body.add_child(collision)
					edge.add_child(body)
			i += 1
		idx += 1
		k += 1
	$CanvasLayer/ProgressBar.value = (idx as float) / (points.size() as float)
	if idx >= points.size():
		set_process(false)
		yield(get_tree().create_timer(1.0), "timeout")
		$CanvasLayer/ProgressBar.hide()
#	call_deferred("save")

func save() -> void:
	var scn = PackedScene.new()
	scn.pack(self)
	ResourceSaver.save("res://TestCity.scn", scn)

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

func gen_pos(i: int) -> Vector2:
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
			rng.randf_range(RECT.position.x, RECT.end.x),
			rng.randf_range(RECT.position.y, RECT.end.y)
		)

	return clamped_to_rect(pos, RECT)

func too_close(pos: Vector2) -> bool:
	for point in points:
		if pos.distance_squared_to(point.position) < MIN_DIST_SQUARED:
			return true
	return false

static func by_distance(a, b):
	return a.dist < b.dist

static func clamped_to_rect(v: Vector2, r: Rect2) -> Vector2:
	return Vector2(
		clamp(v.x, r.position.x, r.end.x),
		clamp(v.y, r.position.y, r.end.y)
	)
