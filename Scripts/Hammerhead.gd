extends RigidBody2D


signal gotGot(who, how)


@export_category("Schmovement")
@export var mag: int
@export var speed: int
@export var turningMag: int
@export var turningSpeed: int
@export var proportionalConstant: int
@export_category("Charging")
@export var orbitDistance: int
@export var perfectOrbitSlow: float
@export var chargingMag: int
@export var chargingSpeed: int
@export var wakeupImpulse: int


var player: RigidBody2D
var UIcontroller: Control
var charging: bool
var stuck: bool
var chargeTimer: Timer
var stuckTimer: Timer
var flashTimer: Timer
var lockedPos: Vector2
var flareLeft: GPUParticles2D
var flareRight: GPUParticles2D
var chargeNoise: AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready():
	charging = false
	stuck = false
	UIcontroller = get_node("/root/Main Scene/UI Controller")
	chargeTimer = get_node("Charge Timer")
	stuckTimer = get_node("Stuck Timer")
	flashTimer = get_node("Flare Flash Timer")
	flareLeft = get_node("Charge Flare Left")
	flareRight = get_node("Charge Flare Right")
	chargeNoise = get_node("Charge Noise")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if charging:
		chargeNoise.playing = true
	else:
		chargeNoise.playing = false


func _integrate_forces(state):
	if player == null:
		var playertree = get_tree().get_nodes_in_group("Player")
		if playertree.is_empty() == true:
			return
		else:
			player = playertree[0]
	var direction = player.transform.get_origin() - transform.get_origin()
	var distance = direction.length()
	direction = direction.normalized()
	var angle = rad_to_deg(atan2(direction.y, direction.x))

	angle -= rad_to_deg(transform.get_rotation())
	if angle > 180:
		angle = (angle - 180) * -1
	elif angle < -180:
		angle = (angle + 180) * -1

	if charging == true:
		state.apply_central_force(lockedPos * chargingMag)
	elif stuck == true:
		pass
	else:
		state.apply_torque((angle/proportionalConstant) * turningMag * -1)
		if distance > orbitDistance:
			state.apply_central_force(direction * mag * (abs(distance-orbitDistance)/proportionalConstant))
		elif distance < orbitDistance:
				state.apply_central_force(direction * mag * (abs(distance-orbitDistance)/proportionalConstant) * -0.5)
		else:
			state.linear_velocity = state.linear_velocity/perfectOrbitSlow
	if state.linear_velocity.length() > speed and (charging == false):
		state.linear_velocity = state.linear_velocity.limit_length(speed)
	elif state.linear_velocity.length() > chargingSpeed and (charging == true):
		state.linear_velocity = state.linear_velocity.limit_length(chargingSpeed)
	if abs(state.angular_velocity) > turningSpeed:
		state.angular_velocity = turningSpeed * signf(state.angular_velocity)

func _on_body_shape_entered(_whomstRID, whomst, _fromst, wherest):
	if wherest == 1:
		if whomst.is_in_group("Lasers") and (whomst.IFF == "P1"):
			emit_signal("gotGot", "Hammerhead", "shot")
			whomst.queue_free()
			queue_free()
		elif whomst.is_in_group("Player"):
			emit_signal("gotGot", "Hammerhead", "headbutted")
			queue_free()
	else:
		if whomst.is_in_group("Lasers"):
			whomst.queue_free()
		else:
			if charging:
				if whomst.is_in_group("Player") or whomst.is_in_group("Enemies"):
					chargeTimer.start()
				else:
					stuck = true
					stuckTimer.start()
#					print("stucked")
			flareLeft.emitting = false
			flareRight.emitting = false
			charging = false


func _time_to_charge():
#	emit_signal("shoot", thePew, (rotation-(PI/2)), position, "AI")
	if player != null:
		lockedPos = (player.transform.get_origin() - transform.get_origin()).normalized()
		flareLeft.emitting = true
		flareRight.emitting = true
		charging = true


func _time_to_unstuck():
	stuck = false
	#HACK: This shouldn't do anything, but it won't unstick unless we apply a force or impulse, so for now it stays.
	var wakeupDir = Vector2.from_angle(randi_range(0, 360))
	apply_central_impulse(wakeupDir * wakeupImpulse)
	if randi_range(0, 1) == 0:
		apply_torque_impulse(wakeupImpulse * -1)
	else:
		apply_torque_impulse(wakeupImpulse)
#	print("unstucked")
	flareLeft.emitting = true
	flareRight.emitting = true
	flashTimer.start()
	chargeTimer.start()


func _time_to_chill():
	flareLeft.emitting = false
	flareRight.emitting = false
