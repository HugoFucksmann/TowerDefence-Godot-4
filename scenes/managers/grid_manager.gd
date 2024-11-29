extends Node2D
class_name GridManager

signal grid_updated

const GRID_SIZE = 32
const GRID_WIDTH = 20
const GRID_HEIGHT = 15

var grid_data: Array = []
var spawn_point: Vector2i = Vector2i(0, 7)
var end_point: Vector2i = Vector2i(19, 7)

func _ready() -> void:
    initialize_grid()
    draw_grid()

func initialize_grid() -> void:
    grid_data.clear()
    for y in range(GRID_HEIGHT):
        var row = []
        for x in range(GRID_WIDTH):
            row.append({
                "occupied": false,
                "type": ""
            })
        grid_data.append(row)

func draw_grid() -> void:
    queue_redraw()

func _draw() -> void:
    for y in range(GRID_HEIGHT):
        for x in range(GRID_WIDTH):
            var rect = Rect2(x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
            draw_rect(rect, Color.WHITE, false)

func is_valid_grid_position(x: int, y: int) -> bool:
    return x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT

func is_area_free(grid_x: int, grid_y: int, width: int, height: int) -> bool:
    for y in range(grid_y, grid_y + height):
        for x in range(grid_x, grid_x + width):
            if not is_valid_grid_position(x, y) or grid_data[y][x]["occupied"]:
                return false
    return true

func occupy_area(grid_x: int, grid_y: int, width: int, height: int, type: String = "tower") -> void:
    for y in range(grid_y, grid_y + height):
        for x in range(grid_x, grid_x + width):
            if is_valid_grid_position(x, y):
                grid_data[y][x]["occupied"] = true
                grid_data[y][x]["type"] = type
    emit_signal("grid_updated")

func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(world_pos.x / GRID_SIZE, world_pos.y / GRID_SIZE)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(grid_pos.x * GRID_SIZE, grid_pos.y * GRID_SIZE)

func get_spawn_position() -> Vector2:
    return grid_to_world(spawn_point)

func get_end_position() -> Vector2:
    return grid_to_world(end_point)
