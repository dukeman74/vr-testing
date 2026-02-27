class_name WeaponProp extends Node3D

@onready var sword_mesh: MeshInstance3D = $Sketchfab_model/Sword_uitlbiaga_High_fbx/RootNode/uitlbiaga_LOD0_TIER1_000/uitlbiaga_LOD0_TIER1_000_MatID_1_0
@onready var swing_path: Node3D = $SwingPath

@export var path_marker:PackedScene

@export var defensive:bool = false
@export var riposte:bool = false

func import_string(string_in:String) -> void:
	var params=string_in.split(",")
	var index:int = 1
	var value:String = params[index]
	if params[0]=="1":
		while(value!="e"):
			var new_mark:Node3D = path_marker.instantiate()
			swing_path.add_child(new_mark)
			new_mark.position.x=float(value)
			new_mark.position.y=float(params[index+1])
			new_mark.position.z=float(params[index+2])
			index+=3
			value=params[index]
		index+=1
	else:
		defensive=true
	var index_lmao=[index]
	var setter:= func():
		var out = float(params[index_lmao[0]])
		index_lmao[0]+=1
		return out
	position.x=setter.call()
	position.y=setter.call()
	position.z=setter.call()
	basis.x.x=setter.call()
	basis.x.y=setter.call()
	basis.x.z=setter.call()
	basis.y.x=setter.call()
	basis.y.y=setter.call()
	basis.y.z=setter.call()
	basis.z.x=setter.call()
	basis.z.y=setter.call()
	basis.z.z=setter.call()

func export_to_string():
	var lmao=[""]
	var add_func = func add_var(variable)->void:
		lmao[0]+="," + str(variable)
	if not defensive:
		add_func.call(1)
		lmao[0] = lmao[0].right(-1)
		for child in swing_path.get_children():
			add_func.call(child.position.x)
			add_func.call(child.position.y)
			add_func.call(child.position.z)
		add_func.call("e")
	else:
		add_func.call(0)
		lmao[0] = lmao[0].right(-1)
	add_func.call(position.x)
	add_func.call(position.y)
	add_func.call(position.z)
	add_func.call(basis.x.x)
	add_func.call(basis.x.y)
	add_func.call(basis.x.z)
	add_func.call(basis.y.x)
	add_func.call(basis.y.y)
	add_func.call(basis.y.z)
	add_func.call(basis.z.x)
	add_func.call(basis.z.y)
	add_func.call(basis.z.z)
	return lmao[0]
