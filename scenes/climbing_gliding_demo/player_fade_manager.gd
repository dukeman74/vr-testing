extends Node


# Damaging flag
var _damaging : bool = false

# Damage cycle
var _damage_cycle : float = 0.0


func _exit_tree() -> void:
	stop_damage()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	# Disable processing if not doing damage
	if not _damaging:
		set_process(false)
		return

	# Advance the cycle counter
	_damage_cycle = fmod(_damage_cycle + delta, 1.0)

	# Generate the cycling alpha value
	var alpha := sin(_damage_cycle * PI * 2)
	alpha = remap(alpha, 1.0, -1.0, 0.0, 0.5)

	# Fade cycling to red tint
	var color := Color(1.0, 0.0, 0.0, alpha/2)
	XRToolsFade.set_fade(self, color)

func start_damage() -> void:
	# Set damaging
	_damaging = true
	_damage_cycle = 0.0
	set_process(true)
	get_tree().create_timer(.2).timeout.connect(stop_damage)

func stop_damage() -> void:
	# Cancel any current damaging effect
	_damaging = false
	XRToolsFade.set_fade(self, Color.TRANSPARENT)
