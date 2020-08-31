extends Spatial

export (int) var max_ammo
export (bool) var automatic
export (float) var cooldown
export (float) var reload_speed
export (float) var shooting_range 
export (float) var damage
onready var ray = $RayCast
onready var anim = $"Add Your Animations"
var ammo

func _ready():
	## SETS THE RAYCAST TO BE AT THE CENTER OF THE SCREEN ##
	ray.global_transform.origin = get_parent().global_transform.origin
	ray.cast_to = Vector3(0,0,-shooting_range)


func _physics_process(delta):
	if Input.is_action_just_pressed("primary_fire"):
		primary_fire()
	elif Input.is_action_just_pressed("secondary_fire"):
		secondary_fire()


func primary_fire():
	anim.play("Shoot")
	if ray.is_colliding():
		print(ray.get_collider())
		if ray.get_collider().has_method("damage"):
			ray.get_collider().damage(damage) 
func secondary_fire():
	pass
