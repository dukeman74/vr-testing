class_name Hitbox extends Area3D

@export var agent_path:NodePath
@onready var agent:Agent=get_node(agent_path)

@export var multiplier:float = 1


func _on_body_entered(body: Node3D) -> void:
	if agent.try_hit(body,multiplier,body.damage): body.make_hit()
