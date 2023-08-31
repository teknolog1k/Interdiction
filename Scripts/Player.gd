extends RigidBody2D

# Testing Git things

signal shoot(laser, direction, location, itsForYou)
signal ouchie(type, location)

@export_group("Schmovement")
@export_subgroup("Base Stats")
@export var mag: int
@export var boostWidth: int
@export var maxSpeed: int
@export var boostMag: int
@export_subgroup("Sliding Stats")
@export var slidingSpeed: int
@export var slideStrength: float
@export_subgroup("Brake Stats")
@export var breaksMin: int
@export var breaksStrength: float

@export_group("Health")
@export var maxHP: float
@export var timeToFullHeal: int

@export_group("Collision Avoidance")
@export var fadeTime: float

var HP: float
var thePew: PackedScene
var healTimer: Timer
var healingActive: bool
var muzzleShine: GPUParticles2D
var muzzleFlash: GPUParticles2D
var collisionAvoidanceShader: Sprite2D
var collisionAvoidanceFade: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	HP = maxHP
	var thisSceneTree = get_tree()
	if thisSceneTree.has_group("Player"):
		add_to_group("Player")
	thePew = preload("res://Scenes/laser.tscn")
	healTimer = get_node("Healing Timer")
	muzzleShine = get_node("Muzzle Shine")
	muzzleFlash = get_node("Muzzle Flash")
	collisionAvoidanceShader = get_node("Collision Avoidance Shader")
	collisionAvoidanceFade = get_node("Collision Avoidance Fade")
	healingActive = false
	HP = maxHP


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("tha_dakka"):
		emit_signal("shoot", thePew, (rotation+(PI/2)), position, "P1")
		muzzleShine.restart()
		muzzleFlash.restart()
	if healingActive:
		HP += maxHP * (delta/timeToFullHeal)
		if HP > maxHP:
			HP = maxHP
			healingActive = false
	if HP <= 0:
		queue_free()



func getInputVec():
	var inputVec = Vector2.ZERO
	if Input.is_action_pressed("schmove_up"):
		inputVec.y -= 1
	if  Input.is_action_pressed("schmove_down"):
		inputVec.y += 1
	if Input.is_action_pressed("schmove_left"):
		inputVec.x -= 1
	if Input.is_action_pressed("schmove_right"):
		inputVec.x += 1
	if inputVec != Vector2.ZERO:
		inputVec = inputVec.normalized()
		return inputVec
	else:
		return null


func _integrate_forces(state):
	var forceVec = getInputVec()
	if forceVec != null:
		var diff = rad_to_deg(abs(forceVec.angle() - (get_local_mouse_position()).rotated(-PI/2).angle()))
		if diff > 180:
			diff = (360-diff)*-1
		elif diff < -180:
			diff = (360+diff)*-1
		if abs(diff) < boostWidth:
			state.apply_central_force(forceVec * boostMag)
#			print('boostin')
		else:
			state.apply_central_force(forceVec * mag)
#			print("cruisin")
	else:
		if state.linear_velocity.length() > slidingSpeed:
			state.linear_velocity = state.linear_velocity.limit_length(state.linear_velocity.length() / slideStrength)
		else:
			linear_damp = 0
	if state.linear_velocity.length() > maxSpeed:
		state.linear_velocity = state.linear_velocity.limit_length(maxSpeed)
	if Input.is_action_pressed("da_breaks") and (state.linear_velocity.length() < breaksMin):
#		state.linear_velocity = state.linear_velocity.limit_length(state.linear_velocity.length() / breaksStrength)
		linear_damp = 10
	elif Input.is_action_pressed("da_breaks"):
		linear_damp = 5
	elif forceVec != null:
		linear_damp = 0
#	print(state.linear_velocity.length())
	look_at(get_global_mouse_position())

func _on_body_entered(they):
	if (they.is_in_group("Lasers")) and (they.IFF == "AI"):
		HP -= 25
		healTimer.start()
		healingActive = false
		they.queue_free()
		emit_signal("ouchie", "sparks", position)
	elif they.is_in_group("Enemies"):
		HP -= 50
		healTimer.start()
		healingActive = false
		emit_signal("ouchie", "sparks", position)
	elif they.is_in_group("World Bounds"):
		collisionAvoidanceFade.play("Collision Flash")

func _on_heal_time():
	healingActive = true
