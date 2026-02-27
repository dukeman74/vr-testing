extends Node

@export var path_to_bar:NodePath
@onready var bar:ProgressBar

@export var path_to_agent:NodePath
@onready var agent:Agent=get_node(path_to_agent)

func _ready() -> void:
	get_bar.call_deferred()

func get_bar():
	bar=get_node(path_to_bar).ui.get_node("ProgressBar")
	update_bar()

func update_bar():
	bar.max_value=agent.max_health
	bar.value=agent.current_health
