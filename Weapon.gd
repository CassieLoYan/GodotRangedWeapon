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
	ray.cast_to = Vector3(0,0,-shooting_range)
	ray.add_exception(player)


func _physics_process(delta):
	if Input.is_action_just_pressed("reload"):
		anim.play("Reload", -1, reload_speed)

	else:
		if !automatic:
			if Input.is_action_just_pressed("primary_fire"):
				primary_fire()
			if Input.is_action_just_pressed("secondary_fire"):
				secondary_fire()
		else:
			if Input.is_action_pressed("secondary_fire"):
				secondary_fire()
			if Input.is_action_pressed("primary_fire"):
				primary_fire()


func primary_fire():
	if ammo > 0 and !(cooldown_timer.time_left > 0):
		_set_spread()
		spread+=spread_per_shot
		spread_timer.start(time_to_reset_spread)
		cooldown_timer.start(cooldown)
		anim.play("Shoot")
		ammo -= ammo_per_shot
		if ray.is_colliding():
			print(ray.get_collider())
			if ray.get_collider().has_method("damage"):
				ray.get_collider().damage(damage) 
			spawn_bullet_decal(ray.get_collision_point(), ray.get_collision_normal(),ray.get_collider())
func secondary_fire():
	pass

func spawn_bullet_decal(point,normal,object):
	var decal = Sprite3D.new()
	decal.texture = bullet_decal
	object.add_child(decal)
	decal.global_transform.origin = point+(Vector3(0.1,0.1,0.1))
	decal.look_at(normal, Vector3.UP)
	decal.rotation_degrees.x+=90
	decal.rotation_degrees.y+=90

func _reset_spread():
	spread = 0
	ray.cast_to = Vector3(0,0,-shooting_range)

func _reload():
	ammo = max_ammo

func _set_spread():
	var spreading = Vector3(rng.randi_range(-spread, spread),rng.randi_range(-spread, spread),0)
	ray.cast_to += spreading
