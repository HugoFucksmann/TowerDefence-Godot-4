extends Node2D

const GRID_SIZE = 32
const GRID_WIDTH = 20
const GRID_HEIGHT = 15

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var tower_scene = preload("res://scenes/tower/tower.tscn")
var nav_region: NavigationRegion2D
var current_tower_preview: Node2D = null
var placing_tower: bool = false
var grid_data: Array = []
var resources: int = 500
var health: int = 20
var spawn_point: Vector2i = Vector2i(0, 7)
var end_point: Vector2i = Vector2i(19, 7)

@onready var wave_manager = $WaveManager
@onready var enemies_container = $EnemiesContainer
@onready var tower_container = $TowerContainer

signal grid_updated

func _ready() -> void:
    initialize_grid()
    draw_grid()
    update_resource_display()
    update_health_label()
    
    # Conectar botones de torres
    for button in $UI/HUD/TowerButtons.get_children():
        button.pressed.connect(_on_tower_button_pressed)
    
    if wave_manager:
        wave_manager.wave_started.connect(_on_wave_started)
        wave_manager.wave_completed.connect(_on_wave_completed)
        wave_manager.all_waves_completed.connect(_on_all_waves_completed)
        wave_manager.start_wave()
    
    nav_region = $NavigationRegion2D
    _update_navigation_polygon()

func initialize_grid() -> void:
    grid_data.clear()
    for y in range(GRID_HEIGHT):
        var row = []
        for x in range(GRID_WIDTH):
            row.append({
                "occupied": false,
                "type": "empty"
            })
        grid_data.append(row)

func draw_grid() -> void:
    queue_redraw()

func _draw() -> void:
    for y in range(GRID_HEIGHT):
        for x in range(GRID_WIDTH):
            var rect = Rect2(x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
            draw_rect(rect, Color.WHITE, false)

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
    
    var grid_pos = world_to_grid(mouse_pos)
    current_tower_preview.position = grid_to_world(grid_pos) + Vector2(GRID_SIZE, GRID_SIZE)
    
    var can_place = can_place_tower(grid_pos.x, grid_pos.y)
    current_tower_preview.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and placing_tower:
        update_tower_preview(event.position)
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if placing_tower:
            try_place_tower(event.position)
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
        if placing_tower:
            cancel_tower_placement()

func try_place_tower(mouse_pos: Vector2) -> void:
    var grid_pos = world_to_grid(mouse_pos)
    
    if can_place_tower(grid_pos.x, grid_pos.y):
        var tower_cost = current_tower_preview.tower_cost
        if resources >= tower_cost:
            resources -= tower_cost
            place_tower(grid_pos)
            update_resource_display()
            cancel_tower_placement()
            start_tower_placement()

func can_place_tower(grid_x: int, grid_y: int) -> bool:
    return is_area_free(grid_x, grid_y, 2, 2)

func place_tower(grid_pos: Vector2i) -> void:
    var tower = tower_scene.instantiate()
    tower.position = grid_to_world(grid_pos) + Vector2(GRID_SIZE, GRID_SIZE)
    if tower_container:
        tower_container.add_child(tower)
    else:
        add_child(tower)
    occupy_area(grid_pos.x, grid_pos.y, 2, 2, "tower")
    _update_navigation_polygon()
    emit_signal("grid_updated")

func cancel_tower_placement() -> void:
    if current_tower_preview:
        current_tower_preview.queue_free()
        current_tower_preview = null
    placing_tower = false

func is_valid_grid_position(grid_x: int, grid_y: int) -> bool:
    return grid_x >= 0 and grid_x < GRID_WIDTH and grid_y >= 0 and grid_y < GRID_HEIGHT

func world_to_grid(pos: Vector2) -> Vector2i:
    return Vector2i(floor(pos.x / GRID_SIZE), floor(pos.y / GRID_SIZE))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(grid_pos.x * GRID_SIZE, grid_pos.y * GRID_SIZE)

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

func update_resource_display() -> void:
    var resource_label = $UI/HUD/ResourcesLabel
    if resource_label:
        resource_label.text = "Resources: %d" % resources

func update_health_label() -> void:
    var health_label = $UI/HUD/HealthLabel
    if health_label:
        health_label.text = "Health: %d" % health

func get_spawn_position() -> Vector2:
    return grid_to_world(spawn_point) + Vector2(GRID_SIZE / 2, GRID_SIZE / 2)

func get_end_position() -> Vector2:
    return grid_to_world(end_point)

func spawn_enemy() -> Node:
    var enemy = enemy_scene.instantiate()
    enemy.position = get_spawn_position()
    if enemies_container:
        enemies_container.add_child(enemy)
    else:
        add_child(enemy)
    return enemy

func add_resources(amount: int) -> void:
    resources += amount
    update_resource_display()

func take_damage(amount: int) -> void:
    health -= amount
    update_health_label()
    
    if health <= 0:
        game_over()

func game_over() -> void:
    print("Game Over!")
    get_tree().paused = true

func _update_navigation_polygon() -> void:
    var nav_polygon = NavigationPolygon.new()
    for y in range(GRID_HEIGHT):
        for x in range(GRID_WIDTH):
            if grid_data[y][x]["occupied"]:
                var rect = Rect2(x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
                nav_polygon.add_outline([rect.position, rect.position + Vector2(GRID_SIZE, 0),
                                         rect.position + Vector2(GRID_SIZE, GRID_SIZE), rect.position + Vector2(0, GRID_SIZE)])
    nav_polygon.make_polygons_from_outlines()
    nav_region.navigation_polygon = nav_polygon

func _on_wave_started(wave_number: int) -> void:
    var wave_label = $UI/HUD/WaveLabel
    if wave_label:
        wave_label.text = "Wave: %d" % wave_number

func _on_wave_completed() -> void:
    add_resources(50)

func _on_all_waves_completed() -> void:
    print("¡Juego completado!")

func _on_tower_button_pressed() -> void:
    start_tower_placement()
