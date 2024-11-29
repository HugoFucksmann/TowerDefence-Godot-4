extends Node

class_name Pathfinding

const GRID_SIZE = 32  # Match with main scene

class PriorityQueue:
	var heap: Array = []
	
	func push(item, priority: float):
		heap.append([priority, item])
		_sift_up(heap.size() - 1)
	
	func pop():
		if heap.is_empty():
			return null
		
		var result = heap[0][1]
		var last_item = heap.pop_back()
		
		if not heap.is_empty():
			heap[0] = last_item
			_sift_down(0)
		
		return result
	
	func is_empty() -> bool:
		return heap.is_empty()
	
	func _sift_up(idx: int):
		while idx > 0:
			var parent_idx = (idx - 1) / 2
			if heap[parent_idx][0] <= heap[idx][0]:
				break
			var temp = heap[parent_idx]
			heap[parent_idx] = heap[idx]
			heap[idx] = temp
			idx = parent_idx
	
	func _sift_down(idx: int):
		while true:
			var smallest = idx
			var left = 2 * idx + 1
			var right = 2 * idx + 2
			
			if left < heap.size() and heap[left][0] < heap[smallest][0]:
				smallest = left
			if right < heap.size() and heap[right][0] < heap[smallest][0]:
				smallest = right
			
			if smallest == idx:
				break
			
			var temp = heap[idx]
			heap[idx] = heap[smallest]
			heap[smallest] = temp
			idx = smallest

static func find_path(grid_data: Array, start: Vector2i, end: Vector2i) -> Array[Vector2]:
	var frontier = PriorityQueue.new()
	frontier.push(start, 0)
	
	var came_from = {}
	var cost_so_far = {}
	came_from[start] = null
	cost_so_far[start] = 0
	
	while not frontier.is_empty():
		var current = frontier.pop()
		
		if current == end:
			break
		
		for next in _get_neighbors(current, grid_data):
			var new_cost = cost_so_far[current] + _movement_cost(current, next)
			
			if not cost_so_far.has(next) or new_cost < cost_so_far[next]:
				cost_so_far[next] = new_cost
				var priority = new_cost + _heuristic(next, end)
				frontier.push(next, priority)
				came_from[next] = current
	
	return _reconstruct_path(came_from, start, end)

static func _get_neighbors(pos: Vector2i, grid_data: Array) -> Array:
	var neighbors = []
	var directions = [
		Vector2i(0, 1),   # Down
		Vector2i(1, 0),   # Right
		Vector2i(0, -1),  # Up
		Vector2i(-1, 0),  # Left
		Vector2i(1, 1),   # Diagonal down-right
		Vector2i(-1, 1),  # Diagonal down-left
		Vector2i(1, -1),  # Diagonal up-right
		Vector2i(-1, -1)  # Diagonal up-left
	]
	
	for dir in directions:
		var next = pos + dir
		if _is_valid_position(next, grid_data) and not _is_blocked(next, grid_data):
			# Verificar que no haya torres en el camino diagonal
			if abs(dir.x) == 1 and abs(dir.y) == 1:
				var corner1 = Vector2i(pos.x + dir.x, pos.y)
				var corner2 = Vector2i(pos.x, pos.y + dir.y)
				if not _is_blocked(corner1, grid_data) and not _is_blocked(corner2, grid_data):
					neighbors.append(next)
			else:
				neighbors.append(next)
	
	return neighbors

static func _is_valid_position(pos: Vector2i, grid_data: Array) -> bool:
	return pos.x >= 0 and pos.x < grid_data[0].size() and pos.y >= 0 and pos.y < grid_data.size()

static func _is_blocked(pos: Vector2i, grid_data: Array) -> bool:
	if not _is_valid_position(pos, grid_data):
		return true
	return grid_data[pos.y][pos.x]["occupied"] or grid_data[pos.y][pos.x]["type"] == "tower"

static func _movement_cost(current: Vector2i, next: Vector2i) -> float:
	# Costo diagonal ligeramente mayor para favorecer caminos rectos cuando sea posible
	return 1.4 if abs(current.x - next.x) + abs(current.y - next.y) == 2 else 1.0

static func _heuristic(a: Vector2i, b: Vector2i) -> float:
	# Usar distancia octil (permite movimientos diagonales)
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	return 1.0 * max(dx, dy) + (1.4 - 1.0) * min(dx, dy)

static func _reconstruct_path(came_from: Dictionary, start: Vector2i, end: Vector2i) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var current = end
	
	if not came_from.has(end):
		return path
	
	while current != start:
		path.push_front(Vector2(current))
		current = came_from[current]
	
	path.push_front(Vector2(start))
	return path
