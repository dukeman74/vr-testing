class_name Enemy extends CharacterBody3D


@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var attack_timer:Timer = $AttackTimer
@onready var damage_timer:Timer = $DamageTimer
@onready var attack_area: Area3D = $Body/Head/AttackArea

@export var attack_range:float

const SPEED = 2.0
const JUMP_VELOCITY = 4.5
var aggro:CharacterBody3D=null:
	set(val):
		if aggro:
			aggro.disconnect("deaggro",lose_aggro)
		aggro=val
		if aggro:
			aggro.connect("deaggro",lose_aggro)
			change_anim("run")
		else:
			change_anim("idle")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func lose_aggro():
	aggro=null

func _physics_process(delta):
	#if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if false and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if aggro:
		var aggro_dir:Vector3 = aggro.global_position-global_position
		var l = aggro_dir.length()
		if l<attack_range and attack_timer.is_stopped():
			attack_timer.start()
			change_anim("bite")
			damage_timer.start()
			change_anim("run",true)
		$Body/Head.rotation.z=sin(aggro_dir.y/l)
		var dif2 = Vector2(aggro_dir.x,-aggro_dir.z)
		
		var direction = (transform.basis * Vector3(1, 0, 0)).normalized()
		#if in attack
		if $AnimationPlayer.current_animation=="bite":
			velocity.x = 0
			velocity.z = 0
		elif direction:
			rotation.y = dif2.angle()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()


func die():
	queue_free()

func change_anim(anim:String,q:bool = false):
	if q:
		anim_player.queue(anim)
		return
	anim_player.play(anim)

func _on_area_3d_body_entered(body):
	aggro=body

func _on_animation_player_animation_finished(_anim_name):
	pass

func _on_damage_timer_timeout():
	for b in attack_area.get_overlapping_bodies():
		if b is XRToolsPlayerBody:
			b.agent.hit(1)
		if b is Weapon:
			b.block_hit(self)
