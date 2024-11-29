extends Node2D

const TOWER_SIZE = 2  # Tower occupies 2x2 grid spaces
const TowerTypes = preload("res://scenes/tower/tower_types.gd")

@export var tower_type: TowerTypes.TowerType = TowerTypes.TowerType.BASIC

var attack_range: float
var attack_damage: float
var attack_speed: float
var tower_cost: int
var targets_air: bool
var splash_damage: bool
var splash_radius: float
var slow_effect: float
var max_targets: int = 1

var attack_timer: float = 0.0
var current_targets: Array = []
var range_circle_points = 32

func _ready():
    apply_tower_type()
    setup_range_indicator()
    $Range/CollisionShape2D.shape.radius = attack_range

func _process(delta):
    attack_timer += delta
    if attack_timer >= 1.0 / attack_speed:
        attack_timer = 0.0
        attack_targets()

func apply_tower_type():
    var data = TowerTypes.TOWER_DATA[tower_type]
    attack_range = data["range"]
    attack_damage = data["damage"]
    attack_speed = data["attack_speed"]
    tower_cost = data["cost"]
    targets_air = data["targets_air"]
    splash_damage = data["splash_damage"]
    slow_effect = data["slow_effect"]
    
    if data.has("splash_radius"):
        splash_radius = data["splash_radius"]
    if data.has("max_targets"):
        max_targets = data["max_targets"]
        
    $Base.color = data["color"]

func setup_range_indicator():
    var range_indicator = $RangeIndicator
    range_indicator.set_script(preload("res://scenes/tower/range_indicator.gd"))

func _on_range_body_entered(body):
    if body.is_in_group("enemies"):
        if can_target_enemy(body) and current_targets.size() < max_targets:
            current_targets.append(body)

func _on_range_body_exited(body):
    current_targets.erase(body)

func can_target_enemy(enemy) -> bool:
    # Si la torre no puede atacar enemigos aéreos y el enemigo es volador, retorna false
    if enemy.is_flying and not targets_air:
        return false
    return true

func attack_targets():
    # Filtrar objetivos inválidos
    current_targets = current_targets.filter(func(target): return is_instance_valid(target))
    
    for target in current_targets:
        if splash_damage:
            var splash_area = get_tree().get_nodes_in_group("enemies").filter(
                func(enemy): return enemy.position.distance_to(target.position) <= splash_radius
            )
            for enemy in splash_area:
                if can_target_enemy(enemy):
                    apply_damage_and_effects(enemy)
        else:
            apply_damage_and_effects(target)

func apply_damage_and_effects(enemy):
    enemy.take_damage(attack_damage)
    if slow_effect > 0:
        enemy.apply_slow(slow_effect)
