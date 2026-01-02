extends Marker3D

func _process(_delta: float) -> void:
	if global.camera:
		look_at(global.camera.global_position)#-global_position)

@onready var viewport_2_din_3d: XRToolsViewport2DIn3DNoInteract = $Viewport2Din3D
@onready var ui:Control = viewport_2_din_3d.scene_node
