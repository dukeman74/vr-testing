extends Node3D


@export var player_agent_path:NodePath

@onready var player_agent:Agent = get_node(player_agent_path)
@export var player_body_path:NodePath

@onready var player_body:XRToolsPlayerBody = get_node(player_body_path)


# Demo staging scene (holds control pad hand choice)
var _staging : DemoStaging
@onready var viewport_2_din_3d: XRToolsViewport2DIn3D = $Viewport2Din3D
var ui:StatsDisplay

func reset_height():
	pass

func set_stats(agent:Agent):
	ui.health_bar.max_value=agent.max_health
	ui.health_bar.value=agent.current_health
	ui.mana_bar.max_value=agent.max_mana
	ui.mana_bar.value=agent.current_mana

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the staging
	_staging = XRTools.find_xr_ancestor(self, "*", "XRToolsStaging") as DemoStaging
	player_agent.stats_changed.connect(set_stats.bind(player_agent))
	# Connect signals
	ui = viewport_2_din_3d.scene_node
	ui.reset_height_button.pressed.connect(player_body.calibrate_player_height)
	

	# Update the control pad location
	_update_location.call_deferred()


# Handle request to switch hand
func _on_switch_hand(hand : String) -> void:
	# Save the hand choice in the DemoStaging instance
	_staging.control_pad_hand = hand

	# Update the control pad location
	_update_location()


# Handle request to switch to main scene
func _on_main_scene() -> void:
	# Find the scene base
	var base := XRTools.find_xr_ancestor(
		self,
		"*",
		"XRToolsSceneBase") as XRToolsSceneBase

	# Return to the main menu
	if base:
		base.exit_to_main_menu()


# Handle request to quit
func _on_quit() -> void:
	# Find the scene base
	var base := XRTools.find_xr_ancestor(
		self,
		"*",
		"XRToolsSceneBase") as XRToolsSceneBase

	# Return to the main menu
	if base:
		base.quit()


# Update the location of this control pad
func _update_location() -> void:
	# Pick the location to set as our parent
	var location : ControlPadLocation
	if _staging.control_pad_hand == "LEFT":
		location = ControlPadLocation.find_left(self)
	else:
		location = ControlPadLocation.find_right(self)

	# Skip if no new location found
	if not location:
		return

	# Detach from current parent
	if get_parent():
		get_parent().remove_child(self)

	# Attach to new parent then zero our transform
	location.add_child(self)
	transform = Transform3D.IDENTITY
	visible = true
