extends Node3D

#@export var track_height_path:NodePath
#@onready var track_height:Node3D = get_node(track_height_path)

@export var weapon_ready:XRToolsRumbleEvent
@export var dev_mode:bool = true
@export var ghost_sword_scene:PackedScene

@export var sword_ghosts:String

var weapon_mesh:Node3D
var weapon:Weapon

var in_swing_setting:WeaponProp=null
var in_swing_attacking:WeaponProp=null

var time_accumulated:float = 0
var swing_progress=0
var swing_node_time:float = 0.04

func export_string():
	var out:String = ""
	for child:WeaponProp in get_children():
		out+=child.export_to_string()+"!"
	out=out.left(-1)
	DisplayServer.clipboard_set(out)

func import_string():
	if sword_ghosts=="": return
	var children=sword_ghosts.split("!")
	for childs_string_data in children:
		var new_child:WeaponProp = ghost_sword_scene.instantiate()
		add_child(new_child)
		new_child.import_string(childs_string_data)
		
func spawn_sword(from:XRToolsPickable, type:bool):
	if from.follow:
		from.state=Weapon.STATE.ATTACKING
		in_swing_attacking=from.follow
		time_accumulated=0
		return
	if not dev_mode: return
	var new_sword:Node3D = ghost_sword_scene.instantiate()
	new_sword.defensive = type
	for child in get_children():
		child.visible=false
	add_child(new_sword)
	set_matching_transform(new_sword,from)
	
	if not type:
		time_accumulated=0
		in_swing_setting=new_sword
		from.action_released.connect(finish_swing_path)
	else:
		export_string()

func set_matching_transform(ghost_sword:Node3D,from:XRToolsPickable):
	ghost_sword.global_transform =\
		from.get_node("Sketchfab_Scene").global_transform

func finish_swing_path(from:XRToolsPickable):
	var new_sword:Node3D = ghost_sword_scene.instantiate()
	in_swing_setting.add_child(new_sword)
	set_matching_transform(new_sword,from)
	in_swing_setting=null
	from.action_released.disconnect(finish_swing_path)
	export_string()
	
func stop_in_swing(done:bool = false):
	for child in in_swing_attacking.swing_path.get_children():
		child.visible=true
	swing_progress=0
	if in_swing_attacking.riposte and done:
		weapon.state=Weapon.STATE.COMBODOWN
	else:
		weapon.state=Weapon.STATE.COOLDOWN
	in_swing_attacking=null

func _ready():
	set_camera.call_deferred()
	weapon_mesh = get_node("../../../Longsword/Sketchfab_Scene")
	weapon = weapon_mesh.get_parent()
	weapon.action_pressed_sided.connect(spawn_sword)
	import_string.call_deferred()

func set_camera():
	global.camera=get_parent()

func _process(delta: float) -> void:
	if in_swing_attacking:
		time_accumulated+=delta
		set_sword_alpha(in_swing_attacking,0)
		var best_index:int=0
		var best_score_in_swing:float = INF
		var child_count = in_swing_attacking.swing_path.get_child_count()
		var weapon_marker_pos:Vector3=weapon.weapon_tip.global_position
		for i in child_count:#-swing_progress:
			#i+=swing_progress
			var this_marker:Node3D=in_swing_attacking.swing_path.get_child(i)
			var this_score:float = (this_marker.global_position-weapon_marker_pos).length()
			if this_score<best_score_in_swing:
				best_score_in_swing=this_score
				best_index=i
		if best_score_in_swing>1.5:
			stop_in_swing()
			return
		if best_index==child_count-1:
			stop_in_swing(true)
			return
		if best_index>swing_progress:
			for i in range(swing_progress,best_index):
				var this_marker:Node3D=in_swing_attacking.swing_path.get_child(i)
				this_marker.visible=false
			swing_progress=best_index
			time_accumulated=0
			return
		if time_accumulated>swing_node_time*2:
			stop_in_swing()
			return
		return
	if in_swing_setting:
		time_accumulated+=delta
		set_sword_alpha(in_swing_setting,0.3)
		if time_accumulated>swing_node_time:
			time_accumulated-=swing_node_time
			var new_path_point:Vector3=weapon_mesh.get_node("../WeaponTip").global_position
			var new_marker:Node3D = in_swing_setting.path_marker.instantiate()
			in_swing_setting.swing_path.add_child(new_marker)
			new_marker.global_position=new_path_point
			#var local_point = (new_path_point-in_swing_setting.global_position)*in_swing_setting.global_basis
			#in_swing_setting.swing_path.curve.add_point(local_point)
		return
	var weapon_state :Weapon.STATE = weapon.state
	
	var closest_child:WeaponProp=null
	var best_score:float = 0
	var wep_state:Weapon.STATE
	var wep_can_swing:bool = false
	for child in get_children():
		child.visible=false
		#set_sword_alpha(child,0)
		var this_score := score_closeness(child)
		if this_score>best_score:
			best_score=this_score
			closest_child=child
	if weapon_state!=Weapon.STATE.DEFENDING and weapon_state!=Weapon.STATE.READY: return
	if closest_child:
		closest_child.visible=true
		set_sword_alpha(closest_child, remap(best_score,0,1,0.05,0.3))
		if best_score>0.7:
			if closest_child.defensive:
				wep_state=Weapon.STATE.DEFENDING
				if closest_child.riposte and weapon.can_riposte:
					closest_child.swing_path.visible=true
					wep_can_swing=true
			else:
				wep_state=Weapon.STATE.READY
				wep_can_swing=true
	if wep_can_swing and weapon.follow==null:
		XRToolsRumbleManager.add("weapon_mesh ready",weapon_ready)
		weapon.follow = closest_child
	if not wep_can_swing:
		weapon.follow=null
	weapon.state=wep_state

func set_sword_alpha(sword_node:Node3D,alpha:float):
	var shader_node = sword_node.sword_mesh
	var base_col = Color.RED
	if sword_node.defensive:
		base_col = Color.GRAY
	shader_node.get_surface_override_material(0).albedo_color\
		=Color(base_col, alpha)

func score_closeness(child:Node3D) -> float:
	var position_delta := weapon_mesh.global_transform.origin.distance_to(child.global_transform.origin)
	if position_delta>.2: return 0
	var dotx:float = weapon_mesh.global_basis.x.dot(child.global_basis.x)
	var doty:float = weapon_mesh.global_basis.y.dot(child.global_basis.y)
	var dotz:float = weapon_mesh.global_basis.z.dot(child.global_basis.z)
	var dot:float = (dotx+doty+dotz)/3
	return dot
	
