class_name Edge
extends Line2D

export var start: NodePath
export var end: NodePath

func update_line():
	var start_pos = get_node(start).position
	var end_pos = get_node(end).position
	points[0] = start_pos
	points[1] = end_pos
