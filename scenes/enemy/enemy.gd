extends CharacterBody2D

@export var max_health: float = 100.0
@export var base_speed: float = 100.0
@export var is_flying: bool = false

var current_health: float
var current_speed: float
var target_position: Vector2
var nav_agent: NavigationAgent2D
var value: int = 10  # Resources gained when killed
var slow_effect: float = 0.0
var slow_duration: float = 0.0

func _ready():
    nav_agent = $NavigationAgent2D
    nav_agent.velocity_computed.connect(_on_velocity_computed)
    
    # Configurar la navegación
    nav_agent.path_desired_distance = 2.0  # Reduce to improve avoidance
    nav_agent.target_desired_distance = 2.0  # Reduce to improve avoidance
    nav_agent.avoidance_enabled = true
    nav_agent.radius = 16.0  # Increase to better detect towers
    nav_agent.neighbor_distance = 64.0  # Increase to better detect towers
    nav_agent.max_neighbors = 15  # Increase to allow more neighbors
    nav_agent.time_horizon = 0.5
    nav_agent.max_speed = base_speed
    
    # Initialize health
    current_health = max_health
    $HealthBar.max_value = max_health
    $HealthBar.value = current_health
    
    # Initialize speed
    current_speed = base_speed
    
    # Add to enemies group
    add_to_group("enemies")
    
    var main = get_tree().get_first_node_in_group("main")
    if main:
        main.connect("grid_updated", Callable(self, "_on_grid_updated"))

func set_target(pos: Vector2):
    target_position = pos
    nav_agent.target_position = target_position

func _physics_process(_delta):
    if slow_duration > 0:
        slow_duration -= _delta
        if slow_duration <= 0:
            remove_slow_effect()
    
    # Verificar si hemos llegado al objetivo
    if nav_agent.is_navigation_finished():
        reached_end()
        return
            
    # Si no hemos llegado, seguir moviéndonos
    var next_path_position: Vector2 = nav_agent.get_next_path_position()
    var direction = global_position.direction_to(next_path_position)
    var desired_velocity = direction * current_speed * (1.0 - slow_effect)
    nav_agent.set_velocity(desired_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
    velocity = safe_velocity
    move_and_slide()

func take_damage(amount: float):
    current_health -= amount
    $HealthBar.value = current_health
    if current_health <= 0:
        die()

func die():
    var main = get_tree().get_first_node_in_group("main")
    if main:
        main.add_resources(value)
    queue_free()

func reached_end():
    var main = get_tree().get_first_node_in_group("main")
    if main:
        main.take_damage(1)
    queue_free()

func _on_grid_updated():
    recalculate_path()

func recalculate_path():
    var main = get_tree().get_first_node_in_group("main")
    if main:
        nav_agent.target_position = main.get_end_position()

func apply_slow(effect: float, duration: float = 2.0):
    if effect > slow_effect:
        slow_effect = effect
        current_speed = base_speed * (1.0 - slow_effect)
    slow_duration = max(slow_duration, duration)

func remove_slow_effect():
    slow_effect = 0.0
    current_speed = base_speed

# Métodos para el wave manager
func set_max_health(new_max_health: float):
    max_health = new_max_health
    current_health = max_health
    $HealthBar.max_value = max_health
    $HealthBar.value = current_health

func set_speed(new_speed: float):
    base_speed = new_speed
    current_speed = base_speed * (1.0 - slow_effect)
    nav_agent.max_speed = base_speed

func get_max_health() -> float:
    return max_health

func get_current_health() -> float:
    return current_health

func set_current_health(value: float):
    current_health = value
    $HealthBar.value = current_health
