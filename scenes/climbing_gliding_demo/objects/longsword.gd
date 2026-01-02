class_name Weapon extends XRToolsPickable

@export var parry_feedback:XRToolsRumbleEvent
@onready var sword_mesh: MeshInstance3D = $Sketchfab_Scene/Sketchfab_model/Sword_uitlbiaga_High_fbx/RootNode/uitlbiaga_LOD0_TIER1_000/uitlbiaga_LOD0_TIER1_000_MatID_1_0
@onready var weapon_tip: Marker3D = $WeaponTip

@onready var parry_sound: AudioStreamPlayer3D = $ParrySound
@onready var swing_sound: AudioStreamPlayer3D = $SwingSound
@onready var equip_sound: AudioStreamPlayer3D = $EquipSound
@onready var hit_sound: AudioStreamPlayer3D = $HitSound

@onready var swing_timeout: Timer = $SwingTimeout
@onready var can_riposte_timer: Timer = $CanRiposteTimer

@export var has_riposte:bool=false

@export var drawn_sound:AudioStream
@export var holstered_sound:AudioStream

@export var required_swing_speed:float

var weapon_logic:ActiveWeaponLogic=null

var damage:float=35

var swing_ready:bool = false

signal swing_concluded

enum STATE {READY, COOLDOWN, DEFENDING, ATTACKING, COMBODOWN}

var follow

var can_riposte:bool = false

func can_hit() -> bool:
	return linear_velocity.length()>required_swing_speed

func make_hit():
	hit_sound.play()

func stop_ripsote():
	can_riposte=false

func re_ready():
	state=STATE.READY
	
var swing_played:bool = false

var state:STATE = STATE.READY:
	set(val):
		var shine_alpha:float=0
		collision_layer=picked_up_layer
		weapon_logic.set_physics_process(false)
		match val:
			STATE.READY:
				pass
			STATE.COMBODOWN:
				follow=null
				if state==STATE.ATTACKING:
					swing_concluded.emit()
				swing_timeout.start()
			STATE.COOLDOWN:
				follow=null
				if state==STATE.ATTACKING:
					swing_concluded.emit()
				swing_timeout.start()
			STATE.DEFENDING:
				shine_alpha=1
				collision_layer=picked_up_layer+(64)
			STATE.ATTACKING:
				swing_played=false
				weapon_logic.set_physics_process(true)
		state=val
		sword_mesh.get_surface_override_material(0).next_pass\
			.set_shader_parameter("shine_color",Color(Color.WHITE,shine_alpha)) 

func update_swinging():
	if state==STATE.ATTACKING:
		if can_hit():
			if not swing_played:
				swing_sound.play()
				swing_played=true
			collision_layer=picked_up_layer+128
		else:
			collision_layer=picked_up_layer


func process_grab_new_code(_me:Weapon, grabbed_by):
	if is_picked_up(): return
	if grabbed_by is XRToolsFunctionPickup:
		equip_sound.stream=drawn_sound
	else:
		equip_sound.stream=holstered_sound
	equip_sound.play()

func block_hit(_hitter:Node):
	parry_sound.play()
	can_riposte_timer.start()
	can_riposte=true
	XRToolsRumbleManager.add("parry",parry_feedback)
