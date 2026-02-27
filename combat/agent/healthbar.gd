extends Control

# Some margin to keep the marker away from the screen's corners.
const MARGIN = 8
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var camera = get_viewport().get_camera_3d()
@onready var parent = get_parent()


func _ready() -> void:
	if not parent is Node3D:
		push_error("The waypoint's parent node must inherit from Node3D.")


func _process(_delta):
	if not camera.current:
		# If the camera we have isn't the current one, get the current camera.
		camera = get_viewport().get_camera_3d()
	var parent_position = parent.global_transform.origin
	var camera_transform = camera.global_transform
	var camera_position = camera_transform.origin

	# We would use "camera.is_position_behind(parent_position)", except
	# that it also accounts for the near clip plane, which we don't want.
	var is_behind = camera_transform.basis.z.dot(parent_position - camera_position) > 0

	# Fade the waypoint when the camera gets close.
	var distance = camera_position.distance_to(parent_position)
	modulate.a = clamp(remap(distance, 0, 2, 0, 1), 0, 1 )

	var unprojected_position = camera.unproject_position(parent_position)
	# `get_size_override()` will return a valid size only if the stretch mode is `2d`.
	# Otherwise, the viewport size is used directly.
	var viewport_base_size = (
			get_viewport().content_scale_size if get_viewport().content_scale_size > Vector2i(0, 0)
			else get_viewport().size
	)
	position = unprojected_position
	visible = not is_behind
	progress_bar.size=Vector2(200,50)/distance
	progress_bar.position=Vector2(-progress_bar.size.x/2,-progress_bar.size.y)
	return
