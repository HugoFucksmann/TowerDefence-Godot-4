extends Node
class_name ResourceManager

signal resources_changed(new_amount: int)
signal health_changed(new_amount: int)

var resources: int = 500
var health: int = 20

func _ready() -> void:
    update_displays()

func add_resources(amount: int) -> void:
    resources += amount
    emit_signal("resources_changed", resources)
    update_displays()

func spend_resources(amount: int) -> bool:
    if resources >= amount:
        resources -= amount
        emit_signal("resources_changed", resources)
        update_displays()
        return true
    return false

func take_damage(amount: int) -> void:
    health -= amount
    emit_signal("health_changed", health)
    update_displays()

func get_resources() -> int:
    return resources

func get_health() -> int:
    return health

func update_displays() -> void:
    var resource_label = get_tree().get_first_node_in_group("resource_label")
    var health_label = get_tree().get_first_node_in_group("health_label")
    
    if resource_label:
        resource_label.text = "Resources: %d" % resources
    if health_label:
        health_label.text = "Health: %d" % health
