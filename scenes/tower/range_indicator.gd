extends Node2D

var range_color = Color(0.2, 0.8, 0.2, 0.2)
var preview_color = Color(0.2, 0.8, 0.2, 0.4)
var invalid_color = Color(0.8, 0.2, 0.2, 0.4)

func _draw():
	var parent = get_parent()
	if not parent:
		return
		
	var radius = parent.attack_range
	var points = parent.range_circle_points
	var angle_delta = 2 * PI / points
	var current_angle = 0
	
	var circle_points = PackedVector2Array()
	for _i in range(points + 1):
		var point = Vector2(
			radius * cos(current_angle),
			radius * sin(current_angle)
		)
		circle_points.push_back(point)
		current_angle += angle_delta
	
	draw_colored_polygon(circle_points, range_color)

func _process(_delta):
	queue_redraw()
