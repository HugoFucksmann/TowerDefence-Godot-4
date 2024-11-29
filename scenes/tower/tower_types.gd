extends Node

enum TowerType {
	BASIC,
	ARTILLERY,
	SLOW,
	ANTI_AIR,
	MULTI_TARGET,
	HYBRID
}

const TOWER_DATA = {
	TowerType.BASIC: {
		"name": "Basic Tower",
		"damage": 10.0,
		"attack_speed": 1.0,
		"range": 150.0,
		"cost": 100,
		"color": Color(0.2, 0.4, 0.8),
		"targets_air": false,
		"splash_damage": false,
		"slow_effect": 0.0
	},
	TowerType.ARTILLERY: {
		"name": "Artillery Tower",
		"damage": 20.0,
		"attack_speed": 0.5,
		"range": 200.0,
		"cost": 150,
		"color": Color(0.8, 0.4, 0.2),
		"targets_air": false,
		"splash_damage": true,
		"splash_radius": 50.0,
		"slow_effect": 0.0
	},
	TowerType.SLOW: {
		"name": "Slow Tower",
		"damage": 5.0,
		"attack_speed": 1.0,
		"range": 120.0,
		"cost": 125,
		"color": Color(0.2, 0.8, 0.8),
		"targets_air": false,
		"splash_damage": false,
		"slow_effect": 0.5
	},
	TowerType.ANTI_AIR: {
		"name": "Anti-Air Tower",
		"damage": 15.0,
		"attack_speed": 1.5,
		"range": 180.0,
		"cost": 150,
		"color": Color(0.8, 0.2, 0.8),
		"targets_air": true,
		"splash_damage": false,
		"slow_effect": 0.0
	},
	TowerType.MULTI_TARGET: {
		"name": "Multi-Target Tower",
		"damage": 8.0,
		"attack_speed": 2.0,
		"range": 160.0,
		"cost": 200,
		"color": Color(0.8, 0.8, 0.2),
		"targets_air": true,
		"max_targets": 3,
		"splash_damage": false,
		"slow_effect": 0.0
	},
	TowerType.HYBRID: {
		"name": "Hybrid Tower",
		"damage": 12.0,
		"attack_speed": 1.0,
		"range": 170.0,
		"cost": 175,
		"color": Color(0.6, 0.4, 0.6),
		"targets_air": true,
		"splash_damage": true,
		"splash_radius": 30.0,
		"slow_effect": 0.2
	}
}
