class_name ActiveWeaponLogic extends Node

@export var weapon_path:NodePath
@onready var weapon:Weapon = get_node(weapon_path)

func _ready() -> void:
	weapon.weapon_logic=self
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	weapon.update_swinging()
