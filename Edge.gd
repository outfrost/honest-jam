extends Line2D

var start: int
var end: int

func update_line(whatever):
	var start_pos = whatever.points[start].pos
	var end_pos = whatever.points[end].pos
	points[0] = start_pos
	points[1] = end_pos
	var collider = $StaticBody2D/CollisionShape2D
	collider.shape = collider.shape.duplicate()
	(collider.shape as SegmentShape2D).a = start_pos
	(collider.shape as SegmentShape2D).b = end_pos
