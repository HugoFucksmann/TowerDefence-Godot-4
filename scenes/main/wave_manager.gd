extends Node

signal wave_started(wave_number: int)
signal wave_completed
signal all_waves_completed

const INITIAL_DELAY = 10.0  # Delay inicial antes de la primera oleada
const WAVE_DELAY = 2.0     # Delay entre oleadas
const SPAWN_INTERVAL = 1.0  # Intervalo entre enemigos

const WAVES_CONFIG = [
    {
        "count": 5,
        "health_multiplier": 1.0,
        "speed_multiplier": 1.0
    },
    {
        "count": 8,
        "health_multiplier": 1.2,
        "speed_multiplier": 1.1
    },
    {
        "count": 10,
        "health_multiplier": 1.5,
        "speed_multiplier": 1.2
    },
    {
        "count": 12,
        "health_multiplier": 2.0,
        "speed_multiplier": 1.3
    },
    {
        "count": 15,
        "health_multiplier": 2.5,
        "speed_multiplier": 1.4
    }
]

var current_wave := 0
var enemies_spawned := 0
var enemies_remaining := 0
var spawn_timer := 0.0
var wave_timer := INITIAL_DELAY  # Iniciar con el delay inicial
var wave_in_progress := false
var main_node: Node

func _ready():
    main_node = get_tree().get_first_node_in_group("main")

func _process(delta):
    if not wave_in_progress:
        # Contar regresivamente hasta la siguiente oleada
        wave_timer -= delta
        if wave_timer <= 0:
            start_wave()
    elif enemies_spawned < WAVES_CONFIG[current_wave]["count"]:
        # Spawning de enemigos durante la oleada
        spawn_timer += delta
        if spawn_timer >= SPAWN_INTERVAL:
            spawn_timer = 0
            spawn_enemy()

func start_wave():
    if current_wave >= WAVES_CONFIG.size():
        emit_signal("all_waves_completed")
        return
        
    wave_in_progress = true
    enemies_spawned = 0
    enemies_remaining = WAVES_CONFIG[current_wave]["count"]
    spawn_timer = 0  # Spawn primer enemigo inmediatamente
    
    emit_signal("wave_started", current_wave + 1)

func spawn_enemy():
    if not main_node:
        return
        
    var enemy = main_node.spawn_enemy()
    if enemy:
        var health_multiplier = WAVES_CONFIG[current_wave]["health_multiplier"]
        var speed_multiplier = WAVES_CONFIG[current_wave]["speed_multiplier"]
        
        # Aplicar multiplicadores
        enemy.set_max_health(enemy.get_max_health() * health_multiplier)
        enemy.set_speed(enemy.base_speed * speed_multiplier)
        
        # Configurar el destino del enemigo
        enemy.set_target(main_node.get_end_position())
        
        enemies_spawned += 1
        enemy.tree_exiting.connect(_on_enemy_destroyed)

func _on_enemy_destroyed():
    enemies_remaining -= 1
    if enemies_remaining <= 0 and enemies_spawned >= WAVES_CONFIG[current_wave]["count"]:
        _on_wave_completed()

func _on_wave_completed():
    wave_in_progress = false
    current_wave += 1
    wave_timer = WAVE_DELAY  # Establecer delay para la siguiente oleada
    emit_signal("wave_completed")
    
    if current_wave >= WAVES_CONFIG.size():
        emit_signal("all_waves_completed")

func get_current_wave() -> int:
    return current_wave + 1

func get_total_waves() -> int:
    return WAVES_CONFIG.size()

func is_wave_in_progress() -> bool:
    return wave_in_progress
