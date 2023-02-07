extends RigidBody2D

@export var speed: int
@export var IFF: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass


func _enter_tree():
#	print("Fire!")
	var adjustedForceVec = Vector2(cos(rotation), sin(rotation))
	adjustedForceVec = adjustedForceVec * speed
	apply_central_force(adjustedForceVec.rotated(-PI/2))
	if IFF == "P1":
		set_collision_layer_value(1, true)
		set_collision_mask_value(1, true)
	elif IFF == "AI":
		set_collision_layer_value(3, true)
		set_collision_mask_value(3, true)
	if get_groups().has("Lasers"):
		add_to_group("Lasers")
	else:
		add_to_group("Lasers")


func _times_up():
	queue_free()
