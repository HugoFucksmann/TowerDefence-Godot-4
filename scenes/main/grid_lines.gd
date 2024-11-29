extends Node2D

var grid_color = Color(0.2, 0.2, 0.2, 0.4)
var grid_thickness = 1.0

func _draw():
	var parent = get_parent().get_parent()
	
	# Draw vertical lines
	for x in range(parent.GRID_WIDTH + 1):
		var from = Vector2(x * parent.GRID_SIZE, 0)
		var to = Vector2(x * parent.GRID_SIZE, parent.GRID_HEIGHT * parent.GRID_SIZE)
		draw_line(from, to, grid_color, grid_thickness)
	
	# Draw horizontal lines
	for y in range(parent.GRID_HEIGHT + 1):
		var from = Vector2(0, y * parent.GRID_SIZE)
		var to = Vector2(parent.GRID_WIDTH * parent.GRID_SIZE, y * parent.GRID_SIZE)
		draw_line(from, to, grid_color, grid_thickness)

func _process(_delta):
	queue_redraw()  # Ensure grid is always visible
