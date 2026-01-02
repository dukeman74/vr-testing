class_name EnemySpawner extends Node3D

@export var enemy_scene:PackedScene

func _ready() -> void:
	spawn_enemy.call_deferred()

func spawn_enemy():
	var new_enemy:Enemy=enemy_scene.instantiate()
	get_parent().get_parent().add_sibling(new_enemy)
	new_enemy.global_position=global_position+Vector3(0,1,0)
	new_enemy.tree_exited.connect(spawn_enemy)
