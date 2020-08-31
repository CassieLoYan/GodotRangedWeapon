extends Spatial
class_name RangedWeapon
export (int) var max_ammo
export (int) var ammo_per_shot
export (bool) var automatic
export (float) var cooldown
export (float) var reload_speed
export (float) var shooting_range 
export (float) var damage
export (float) var spread_per_shot
export (float) var max_spread
export (float) var time_to_reset_spread
export (Texture) var bullet_decal
export (Texture) var aim_reticle

onready var ray = $RayCast
onready var anim = $"Add Your Animations"
onready var cam = get_parent()
onready var player = get_parent().get_parent()
onready var cooldown_timer = Timer.new()
onready var spread_timer = Timer.new()
onready var rng = RandomNumberGenerator.new()

var ammo
var spread = 0

func _ready():
	randomize()
	rng.randomize()
	$AimReticle.texture = aim_reticle
	ammo = max_ammo
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	add_child(spread_timer)
	spread_timer.one_shot = true
	spread_timer.connect("timeout", self, "_reset_spread")
	## SETS THE RAYCAST TO BE AT THE CENTER OF THE SCREEN ##
	ray.global_transform.origin = cam.global_transform.origin
	## SETS THE SHOOTING RANGE ##
	ray.cast_to = Vector3(0,0,-shooting_range)
	## MAKES THE RAY NOT COLLIDE WITH THE PLAYER ##
	ray.add_exception(player)


func _physics_process(delta):
	## RELOADS THE WEAPON ##
	if Input.is_action_just_pressed("reload"):
		anim.play("Reload", -1, reload_speed)
	else:
		## SHOOTS ONCE EVERY TIME THE BUTTON IS CLICKED ##
		if !automatic:
			if Input.is_action_just_pressed("primary_fire"):
				primary_fire()
			if Input.is_action_just_pressed("secondary_fire"):
				secondary_fire()
		## SHOOTS WHILE THE BUTTON IS BEING HELD ##
		else:
			if Input.is_action_pressed("secondary_fire"):
				secondary_fire()
			if Input.is_action_pressed("primary_fire"):
				primary_fire()


func primary_fire():
	if ammo > 0 and !(cooldown_timer.time_left > 0):
		## ADDS SPREAD TO THE SHOT ##
		_set_spread()
		spread+=spread_per_shot
		spread_timer.start(time_to_reset_spread)
		## STARTS THE SHOOTING COOLDOWN ##
		cooldown_timer.start(cooldown)
		## PLAYS THE SHOOTING ANIMATION ##
		anim.play("Shoot")
		ammo -= ammo_per_shot
		if ray.is_colliding():
			## DAMAGES WHAT THE PLAYER SHOT AT ##
			if ray.get_collider().has_method("damage"):
				ray.get_collider().damage(damage, ray.get_collision_point(), ray.get_collision_normal()) 

func secondary_fire():
	pass

## RESETS THE WEAPON SPREAD WHENEVER THE SPREAD COOLDOWN IS UP ##
func _reset_spread():
	spread = 0
	ray.cast_to = Vector3(0,0,-shooting_range)

## CALLED AT SOME POINT IN THE RELOADING ANIMATION ##
func _reload():
	ammo = max_ammo

func _set_spread():
	var spreading = Vector3(rng.randi_range(-spread, spread),rng.randi_range(-spread, spread),0)
	ray.cast_to += spreading
