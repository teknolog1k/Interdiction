extends RigidBody2D


signal gotGot(who, how)
signal shoot(laser, direction, location, itsForYou)

@export_category("Schmovement")
@export var mag: int
@export var speed: int
@export var turningMag: int
@export var turningSpeed: int


var player: RigidBody2D
var UIcontroller: Control
var thePew: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	UIcontroller = get_node("/root/Node2D/UI Controller")
	thePew = preload("res://Scenes/laser.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if player == null:
#		player = get_tree().get_root().find_node("Player")
#	var direction = player.transform.get_origin() - transform.get_origin()
#	direction = direction.normalized()
#	var angle = rad_to_deg(atan2(direction.y, direction.x))


func _integrate_forces(state):
	if player == null:
		var playertree = get_tree().get_nodes_in_group("Player")
		if playertree.is_empty() == true:
			return
		else:
			player = playertree[0]
	var direction = player.transform.get_origin() - transform.get_origin()
	direction = direction.normalized()
	var angle = rad_to_deg(atan2(direction.y, direction.x))
	angle -= rad_to_deg(transform.get_rotation())
	if angle > 180:
		angle = (angle - 180) * -1
	elif angle < -180:
		angle = (angle + 180) * -1
#	print(angle/10)
	
	state.apply_central_force(direction * mag * (direction.length()/10))
	state.apply_torque((angle/10) * turningMag * -1)
	
	if state.linear_velocity.length() > speed:
		state.linear_velocity = state.linear_velocity.limit_length(speed)
	if abs(state.angular_velocity) > turningSpeed:
		state.angular_velocity = turningSpeed * signf(state.angular_velocity)

func _on_body_entered(whomst):
	if whomst.is_in_group("Lasers") and (whomst.IFF == "P1"):
		emit_signal("gotGot", "AI Pirate", "shot")
		whomst.queue_free()
		queue_free()
	elif whomst.is_in_group("Player"):
		emit_signal("gotGot", "AI Pirate", "headbutted")
		queue_free()


func _time_to_fire():
	emit_signal("shoot", thePew, (rotation-(PI/2)), position, "AI")

