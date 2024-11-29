extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var main = get_tree().get_first_node_in_group("main")
	if main:
		main.start_tower_placement()
