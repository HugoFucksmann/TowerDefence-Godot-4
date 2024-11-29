extends Node2D
class_name TowerManager

signal tower_placed(position: Vector2)

var tower_scene = preload("res://scenes/tower/tower.tscn")
var current_tower_preview: Node2D = null
var placing_tower: bool = false

var grid_manager: GridManager
var resource_manager: ResourceManager

func _ready() -> void:
    grid_manager = get_tree().get_first_node_in_group("grid_manager")
    resource_manager = get_tree().get_first_node_in_group("resource_manager")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and placing_tower:
        update_tower_preview(event.position)
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if placing_tower:
            try_place_tower(event.position)
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
        if placing_tower:
            cancel_tower_placement()

func start_tower_placement() -> void:
    if placing_tower:
        return
        
    placing_tower = true
    current_tower_preview = tower_scene.instantiate()
    current_tower_preview.modulate.a = 0.5
    add_child(current_tower_preview)
    update_tower_preview(get_viewport().get_mouse_position())

func update_tower_preview(mouse_pos: Vector2) -> void:
    if not current_tower_preview:
        return
        
    var grid_pos = grid_manager.world_to_grid(mouse_pos)
    current_tower_preview.position = grid_manager.grid_to_world(grid_pos) + Vector2(grid_manager.GRID_SIZE, grid_manager.GRID_SIZE)
    
    var can_place = grid_manager.is_area_free(grid_pos.x, grid_pos.y, 2, 2)
    current_tower_preview.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

func try_place_tower(mouse_pos: Vector2) -> void:
    var grid_pos = grid_manager.world_to_grid(mouse_pos)
    
    if grid_manager.is_area_free(grid_pos.x, grid_pos.y, 2, 2):
        var tower_cost = current_tower_preview.tower_cost
        if resource_manager.spend_resources(tower_cost):
            place_tower(grid_pos)
            cancel_tower_placement()
            start_tower_placement()

func place_tower(grid_pos: Vector2i) -> void:
    var tower = tower_scene.instantiate()
    tower.position = grid_manager.grid_to_world(grid_pos) + Vector2(grid_manager.GRID_SIZE, grid_manager.GRID_SIZE)
    add_child(tower)
    grid_manager.occupy_area(grid_pos.x, grid_pos.y, 2, 2, "tower")
    emit_signal("tower_placed", tower.position)

func cancel_tower_placement() -> void:
    if current_tower_preview:
        current_tower_preview.queue_free()
        current_tower_preview = null
    placing_tower = false
