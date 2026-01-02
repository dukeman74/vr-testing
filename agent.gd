class_name Agent extends Node

@export var max_health:float = 100
@export var max_mana:float = 10
@export var intelligence:int = 25
@export var dexterity:int = 25
@export var strength:int = 25
@export var knowledge:int = 25

@export var hit_rumble:XRToolsRumbleEvent

@onready var current_health:float = max_health
@onready var current_mana:float = max_mana

signal taken_damage(damage:float)
signal died
signal stats_changed

var immune_to:Dictionary = {}

func try_hit(weapon:Weapon,multiplier:float,damage:float) -> bool:
	if weapon in immune_to: return false
	immune_to[weapon]=true
	weapon.swing_concluded.connect(remove_from_immune.bind(weapon))
	XRToolsRumbleManager.add("swing_connected",hit_rumble)
	hit(damage*multiplier)
	return true
	
func remove_from_immune(weapon:Weapon):
	immune_to.erase(weapon)
	weapon.swing_concluded.disconnect(remove_from_immune)

func hit(damage:float) -> bool:
	var pre_health:=current_health
	current_health = clampf(current_health-damage,0,max_health)
	if current_health==pre_health: return false
	taken_damage.emit(pre_health-current_health)
	stats_changed.emit()
	var died_from_this_hit:=false
	if current_health==0:
		died.emit()
		died_from_this_hit=true
	return died_from_this_hit
